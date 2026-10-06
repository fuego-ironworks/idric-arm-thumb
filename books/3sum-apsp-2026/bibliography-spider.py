#!/usr/bin/env python3
"""Build a one-level recursive bibliography from the direct citation seed list.

Depth:
    primary paper -> direct references -> references of each direct reference

The final level is bibliographic only. It is not expanded recursively and
inclusion does not imply that the work has been read.

Resolution is fail-closed: ambiguous title matches are reported unresolved
rather than silently attached to the wrong paper.
"""

from __future__ import annotations

import argparse
import csv
import difflib
import json
import os
import re
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

OPENALEX = "https://api.openalex.org"
HERE = Path(__file__).resolve().parent
DEFAULT_SEEDS = HERE / "direct-citations.tsv"
DEFAULT_OUTPUT = HERE / "one-hop-bibliography.md"
DEFAULT_REPORT = HERE / "spider-report.json"


@dataclass(frozen=True)
class Seed:
    key: str
    year: int
    authors: str
    title: str


def normalize_title(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.lower().replace("–", "-").replace("—", "-").replace("−", "-")
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return " ".join(text.split())


def surname_hint(authors: str) -> str:
    first = authors.split(";", 1)[0].strip()
    words = normalize_title(first).split()
    return words[-1] if words else ""


def read_seeds(path: Path) -> list[Seed]:
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        return [
            Seed(
                key=row["key"].strip(),
                year=int(row["year"]),
                authors=row["authors"].strip(),
                title=row["title"].strip(),
            )
            for row in reader
        ]


class OpenAlexClient:
    def __init__(self, pause: float = 0.13, retries: int = 5) -> None:
        self.pause = pause
        self.retries = retries
        self.mailto = os.environ.get("OPENALEX_MAILTO", "").strip()
        self.user_agent = "idric-arm-thumb-bibliography-spider/1"

    def request(self, path: str, params: dict[str, str]) -> dict[str, Any]:
        query = dict(params)
        if self.mailto:
            query["mailto"] = self.mailto
        url = f"{OPENALEX}{path}?{urllib.parse.urlencode(query)}"
        last_error: Exception | None = None

        for attempt in range(self.retries):
            try:
                req = urllib.request.Request(
                    url,
                    headers={"Accept": "application/json", "User-Agent": self.user_agent},
                )
                with urllib.request.urlopen(req, timeout=45) as response:
                    payload = json.load(response)
                time.sleep(self.pause)
                return payload
            except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError) as exc:
                last_error = exc
                time.sleep(min(8.0, 0.5 * (2 ** attempt)))

        raise RuntimeError(f"OpenAlex request failed after retries: {url}: {last_error}")

    def resolve_seed(self, seed: Seed) -> tuple[dict[str, Any] | None, dict[str, Any]]:
        payload = self.request(
            "/works",
            {
                "search": seed.title,
                "per-page": "8",
                "select": (
                    "id,doi,title,publication_year,authorships,"
                    "referenced_works,primary_location,type"
                ),
            },
        )
        wanted = normalize_title(seed.title)
        hint = surname_hint(seed.authors)
        scored: list[tuple[float, dict[str, Any], dict[str, Any]]] = []

        for work in payload.get("results", []):
            got = normalize_title(work.get("title") or "")
            title_similarity = difflib.SequenceMatcher(None, wanted, got).ratio()
            score = title_similarity

            year = work.get("publication_year")
            if year == seed.year:
                score += 0.04
            elif isinstance(year, int) and abs(year - seed.year) == 1:
                score += 0.01

            names = " ".join(
                normalize_title((item.get("author") or {}).get("display_name") or "")
                for item in work.get("authorships") or []
            )
            if hint and hint in names.split():
                score += 0.04

            scored.append(
                (
                    score,
                    work,
                    {
                        "title_similarity": title_similarity,
                        "score": score,
                        "candidate_title": work.get("title"),
                        "candidate_year": year,
                    },
                )
            )

        if not scored:
            return None, {"reason": "no candidates"}

        scored.sort(key=lambda item: item[0], reverse=True)
        score, work, diagnostic = scored[0]

        if diagnostic["title_similarity"] < 0.84 or score < 0.88:
            diagnostic["reason"] = "best candidate below acceptance threshold"
            return None, diagnostic

        return work, diagnostic

    def fetch_works(self, ids: Iterable[str]) -> dict[str, dict[str, Any]]:
        clean = [item.rsplit("/", 1)[-1] for item in ids if item]
        found: dict[str, dict[str, Any]] = {}

        for offset in range(0, len(clean), 40):
            batch = clean[offset : offset + 40]
            payload = self.request(
                "/works",
                {
                    "filter": "openalex_id:" + "|".join(batch),
                    "per-page": "200",
                    "select": "id,doi,title,publication_year,authorships,type",
                },
            )
            for work in payload.get("results", []):
                found[work["id"]] = work

        return found


def author_string(work: dict[str, Any], limit: int = 6) -> str:
    names = [
        (item.get("author") or {}).get("display_name")
        for item in work.get("authorships") or []
    ]
    names = [name for name in names if name]
    if not names:
        return "unknown author"
    if len(names) <= limit:
        return ", ".join(names)
    return ", ".join(names[:limit]) + ", et al."


def work_line(work: dict[str, Any]) -> str:
    title = (work.get("title") or "untitled").strip()
    year = work.get("publication_year") or "n.d."
    authors = author_string(work)
    doi = work.get("doi")
    openalex_id = work.get("id")
    identifiers = []
    if doi:
        identifiers.append(str(doi))
    if openalex_id:
        identifiers.append(str(openalex_id))
    suffix = " — " + " | ".join(identifiers) if identifiers else ""
    return f"{authors} ({year}), *{title}*{suffix}"


def build(seeds: list[Seed], client: OpenAlexClient) -> tuple[str, dict[str, Any]]:
    resolved: dict[str, dict[str, Any]] = {}
    diagnostics: dict[str, dict[str, Any]] = {}
    unresolved: dict[str, dict[str, Any]] = {}

    for index, seed in enumerate(seeds, 1):
        work, diagnostic = client.resolve_seed(seed)
        diagnostics[seed.key] = diagnostic
        if work is None:
            unresolved[seed.key] = {"seed": seed.__dict__, "diagnostic": diagnostic}
        else:
            resolved[seed.key] = work
        state = "resolved" if work else "UNRESOLVED"
        print(f"[{index:03d}/{len(seeds):03d}] {seed.key}: {state}", flush=True)

    wanted_children: set[str] = set()
    cited_by: dict[str, set[str]] = defaultdict(set)
    for key, work in resolved.items():
        for openalex_id in work.get("referenced_works") or []:
            wanted_children.add(openalex_id)
            cited_by[openalex_id].add(key)

    children = client.fetch_works(sorted(wanted_children))

    lines: list[str] = []
    lines.append("# One-level recursive bibliography")
    lines.append("")
    lines.append(
        "Generated from direct-citations.tsv through OpenAlex. This follows "
        "the primary paper's direct references exactly one further bibliographic "
        "level. It does not follow the works below recursively, and inclusion "
        "does not mean a work has been read."
    )
    lines.append("")
    lines.append(f"- direct seeds: {len(seeds)}")
    lines.append(f"- resolved direct works: {len(resolved)}")
    lines.append(f"- unresolved direct works: {len(unresolved)}")
    lines.append(f"- unique second-hop OpenAlex ids requested: {len(wanted_children)}")
    lines.append(f"- unique second-hop works resolved: {len(children)}")
    lines.append("")
    lines.append("## Bibliography by direct cited work")
    lines.append("")

    seed_by_key = {seed.key: seed for seed in seeds}
    for seed in seeds:
        lines.append(f"### {seed.key} — {seed.title}")
        lines.append("")
        work = resolved.get(seed.key)
        if work is None:
            lines.append(
                "**UNRESOLVED.** No OpenAlex candidate cleared the title-match threshold."
            )
            lines.append("")
            continue

        lines.append("Resolved as: " + work_line(work))
        lines.append("")
        references = work.get("referenced_works") or []
        if not references:
            lines.append("_OpenAlex records no references for this work._")
            lines.append("")
            continue

        rendered = []
        for openalex_id in references:
            child = children.get(openalex_id)
            if child is not None:
                rendered.append(work_line(child))
            else:
                rendered.append(f"unresolved OpenAlex work id {openalex_id}")

        for item in sorted(rendered, key=str.casefold):
            lines.append(f"- {item}")
        lines.append("")

    lines.append("## Union of second-hop works")
    lines.append("")
    union = sorted(
        children.values(),
        key=lambda work: (
            normalize_title(work.get("title") or ""),
            work.get("publication_year") or 0,
        ),
    )
    for work in union:
        openalex_id = work.get("id", "")
        parents = ", ".join(sorted(cited_by.get(openalex_id, set())))
        lines.append(f"- {work_line(work)} — cited by direct seed(s): {parents}")
    lines.append("")

    lines.append("## Unresolved direct seeds")
    lines.append("")
    if not unresolved:
        lines.append("None.")
    else:
        for key, item in unresolved.items():
            seed = item["seed"]
            diagnostic = item["diagnostic"]
            encoded = json.dumps(diagnostic, ensure_ascii=False)
            lines.append(
                f"- **{key}** — {seed['authors']} ({seed['year']}), "
                f"*{seed['title']}*. Diagnostic: {encoded}"
            )
    lines.append("")

    report = {
        "seed_count": len(seeds),
        "resolved_direct_count": len(resolved),
        "unresolved_direct_count": len(unresolved),
        "second_hop_id_count": len(wanted_children),
        "second_hop_resolved_count": len(children),
        "resolved": {
            key: {
                "id": work.get("id"),
                "doi": work.get("doi"),
                "title": work.get("title"),
                "publication_year": work.get("publication_year"),
                "reference_count": len(work.get("referenced_works") or []),
                "diagnostic": diagnostics[key],
            }
            for key, work in resolved.items()
        },
        "unresolved": unresolved,
    }

    return "\n".join(lines), report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seeds", type=Path, default=DEFAULT_SEEDS)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--pause", type=float, default=0.13)
    args = parser.parse_args()

    seeds = read_seeds(args.seeds)
    markdown, report = build(seeds, OpenAlexClient(pause=args.pause))
    args.output.write_text(markdown + "\n", encoding="utf-8")
    args.report.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    print(
        f"wrote {args.output} and {args.report}: "
        f"{report['resolved_direct_count']}/{report['seed_count']} direct seeds resolved; "
        f"{report['second_hop_resolved_count']} second-hop works",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
