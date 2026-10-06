#!/usr/bin/env python3
"""Build one recursive bibliography level from the direct citation seed list.

Depth:
    primary paper -> direct references -> bibliography of each direct reference

The final level is bibliographic only. It is not recursively expanded and
inclusion does not imply that the work has been read.

Crossref is used for bibliographic/reference metadata. Resolution is
fail-closed: ambiguous title matches are reported unresolved rather than
silently attached to the wrong work. Crossref reference deposits can
themselves be incomplete, so missing deposited bibliographies are reported.
"""

from __future__ import annotations

import argparse
import csv
import difflib
import json
import re
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

CROSSREF = "https://api.crossref.org"
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


def normalize(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.lower().replace("–", "-").replace("—", "-").replace("−", "-")
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return " ".join(text.split())


def first_surname(authors: str) -> str:
    first = authors.split(";", 1)[0].strip()
    words = normalize(first).split()
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


def work_title(item: dict[str, Any]) -> str:
    title = item.get("title") or []
    if isinstance(title, list):
        return str(title[0]) if title else ""
    return str(title)


def work_year(item: dict[str, Any]) -> int | None:
    for key in ("published-print", "published-online", "published", "issued"):
        block = item.get(key) or {}
        parts = block.get("date-parts") or []
        if parts and parts[0]:
            try:
                return int(parts[0][0])
            except (TypeError, ValueError, IndexError):
                pass
    return None


def work_authors(item: dict[str, Any], limit: int = 8) -> str:
    names: list[str] = []
    for author in item.get("author") or []:
        family = str(author.get("family") or "").strip()
        given = str(author.get("given") or "").strip()
        name = " ".join(part for part in (given, family) if part)
        if name:
            names.append(name)
    if not names:
        return "unknown author"
    if len(names) > limit:
        return ", ".join(names[:limit]) + ", et al."
    return ", ".join(names)


class CrossrefClient:
    def __init__(self, pause: float = 0.40, retries: int = 8) -> None:
        self.pause = pause
        self.retries = retries
        self.user_agent = (
            "idric-arm-thumb-bibliography-spider/2 "
            "(https://github.com/fuego-ironworks/idric-arm-thumb)"
        )

    def request(self, path: str, params: dict[str, str]) -> dict[str, Any]:
        url = f"{CROSSREF}{path}?{urllib.parse.urlencode(params)}"
        last_error: Exception | None = None

        for attempt in range(self.retries):
            try:
                request = urllib.request.Request(
                    url,
                    headers={
                        "Accept": "application/json",
                        "User-Agent": self.user_agent,
                    },
                )
                with urllib.request.urlopen(request, timeout=45) as response:
                    payload = json.load(response)
                time.sleep(self.pause)
                return payload
            except urllib.error.HTTPError as exc:
                last_error = exc
                retry_after = exc.headers.get("Retry-After")
                try:
                    retry_seconds = float(retry_after) if retry_after else 0.0
                except ValueError:
                    retry_seconds = 0.0
                if exc.code in (429, 503):
                    time.sleep(max(retry_seconds, min(60.0, 3.0 * (attempt + 1))))
                else:
                    time.sleep(min(20.0, 0.75 * (2 ** attempt)))
            except (urllib.error.URLError, TimeoutError) as exc:
                last_error = exc
                time.sleep(min(20.0, 0.75 * (2 ** attempt)))

        raise RuntimeError(f"Crossref request failed after retries: {url}: {last_error}")

    def resolve(self, seed: Seed) -> tuple[dict[str, Any] | None, dict[str, Any]]:
        payload = self.request(
            "/works",
            {
                "query.bibliographic": seed.title,
                "rows": "8",
            },
        )
        candidates = (payload.get("message") or {}).get("items") or []
        wanted = normalize(seed.title)
        surname = first_surname(seed.authors)
        scored: list[tuple[float, dict[str, Any], dict[str, Any]]] = []

        for item in candidates:
            candidate_title = work_title(item)
            title_similarity = difflib.SequenceMatcher(
                None, wanted, normalize(candidate_title)
            ).ratio()
            score = title_similarity

            year = work_year(item)
            if year == seed.year:
                score += 0.04
            elif year is not None and abs(year - seed.year) == 1:
                score += 0.01

            candidate_families = {
                normalize(str(author.get("family") or ""))
                for author in item.get("author") or []
            }
            if surname and surname in candidate_families:
                score += 0.04

            diagnostic = {
                "title_similarity": title_similarity,
                "score": score,
                "candidate_title": candidate_title,
                "candidate_year": year,
                "candidate_doi": item.get("DOI"),
            }
            scored.append((score, item, diagnostic))

        if not scored:
            return None, {"reason": "no candidates"}

        scored.sort(key=lambda row: row[0], reverse=True)
        score, item, diagnostic = scored[0]

        if diagnostic["title_similarity"] < 0.84 or score < 0.88:
            diagnostic["reason"] = "best candidate below acceptance threshold"
            return None, diagnostic

        return item, diagnostic


def clean_field(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, list):
        return "; ".join(clean_field(part) for part in value if clean_field(part))
    return re.sub(r"\s+", " ", str(value)).strip()


def render_reference(ref: dict[str, Any]) -> str:
    unstructured = clean_field(ref.get("unstructured"))
    doi = clean_field(ref.get("DOI"))

    parts: list[str] = []
    author = clean_field(ref.get("author"))
    year = clean_field(ref.get("year"))
    title = clean_field(ref.get("article-title")) or clean_field(ref.get("volume-title"))
    journal = clean_field(ref.get("journal-title"))
    volume = clean_field(ref.get("volume"))
    issue = clean_field(ref.get("issue"))
    first_page = clean_field(ref.get("first-page"))

    if author:
        parts.append(author)
    if year:
        parts.append(f"({year})")
    if title:
        parts.append(title)
    if journal:
        parts.append(journal)
    if volume:
        volume_text = f"vol. {volume}"
        if issue:
            volume_text += f"({issue})"
        parts.append(volume_text)
    elif issue:
        parts.append(f"issue {issue}")
    if first_page:
        parts.append(f"p. {first_page}")

    structured = ". ".join(parts)
    if unstructured and structured:
        text = structured + ". Deposited citation: " + unstructured
    elif unstructured:
        text = unstructured
    elif structured:
        text = structured
    elif doi:
        text = "DOI " + doi
    else:
        serial = json.dumps(ref, ensure_ascii=False, sort_keys=True)
        text = "Crossref reference metadata: " + serial

    if doi and doi.lower() not in text.lower():
        text += f". DOI {doi}"

    return re.sub(r"\s+", " ", text).strip()


def reference_identity(ref: dict[str, Any]) -> str:
    doi = clean_field(ref.get("DOI")).lower()
    if doi:
        return "doi:" + doi
    return "text:" + normalize(render_reference(ref))


def direct_work_line(seed: Seed, item: dict[str, Any]) -> str:
    authors = work_authors(item)
    year = work_year(item) or seed.year
    title = work_title(item) or seed.title
    doi = clean_field(item.get("DOI"))
    suffix = f" — https://doi.org/{doi}" if doi else ""
    return f"{authors} ({year}), *{title}*{suffix}"


def build(seeds: list[Seed], client: CrossrefClient) -> tuple[str, dict[str, Any]]:
    resolved: dict[str, dict[str, Any]] = {}
    diagnostics: dict[str, dict[str, Any]] = {}
    unresolved: dict[str, dict[str, Any]] = {}

    for index, seed in enumerate(seeds, 1):
        try:
            item, diagnostic = client.resolve(seed)
        except RuntimeError as exc:
            item = None
            diagnostic = {"reason": "request failure", "error": str(exc)}

        diagnostics[seed.key] = diagnostic
        if item is None:
            unresolved[seed.key] = {
                "seed": seed.__dict__,
                "diagnostic": diagnostic,
            }
        else:
            resolved[seed.key] = item

        state = "resolved" if item is not None else "UNRESOLVED"
        reference_count = len((item or {}).get("reference") or [])
        print(
            f"[{index:03d}/{len(seeds):03d}] {seed.key}: "
            f"{state}, deposited references={reference_count}",
            flush=True,
        )

    union: dict[str, dict[str, Any]] = {}
    cited_by: dict[str, set[str]] = defaultdict(set)

    for key, item in resolved.items():
        for ref in item.get("reference") or []:
            identity = reference_identity(ref)
            if not identity or identity == "text:":
                continue
            union.setdefault(identity, ref)
            cited_by[identity].add(key)

    lines: list[str] = []
    lines.append("# One-level recursive bibliography")
    lines.append("")
    lines.append(
        "Generated from direct-citations.tsv using Crossref metadata and deposited "
        "reference lists. The recursion depth is exactly one beyond the primary "
        "paper's direct references. The references below are not themselves "
        "expanded, and inclusion does not mean they have been read."
    )
    lines.append("")
    lines.append(
        "Crossref deposits are not guaranteed to contain a publisher's complete "
        "reference list. A direct work with no deposited references is marked "
        "explicitly instead of being treated as if its bibliography were empty."
    )
    lines.append("")
    lines.append(f"- direct seeds: {len(seeds)}")
    lines.append(f"- resolved direct works: {len(resolved)}")
    lines.append(f"- unresolved direct works: {len(unresolved)}")
    lines.append(
        f"- resolved direct works with deposited references: "
        f"{sum(1 for item in resolved.values() if item.get('reference'))}"
    )
    lines.append(f"- unique deposited second-hop references: {len(union)}")
    lines.append("")
    lines.append("## Bibliography by direct cited work")
    lines.append("")

    for seed in seeds:
        lines.append(f"### {seed.key} — {seed.title}")
        lines.append("")
        item = resolved.get(seed.key)
        if item is None:
            lines.append(
                "**UNRESOLVED.** No Crossref candidate cleared the title-match "
                "threshold, or the request failed."
            )
            lines.append("")
            continue

        lines.append("Resolved as: " + direct_work_line(seed, item))
        lines.append("")
        refs = item.get("reference") or []
        if not refs:
            lines.append(
                "_No reference list is present in this work's Crossref deposit. "
                "This is recorded as missing metadata, not as an empty bibliography._"
            )
            lines.append("")
            continue

        for ref in refs:
            lines.append("- " + render_reference(ref))
        lines.append("")

    lines.append("## Union of second-hop bibliography")
    lines.append("")
    for identity in sorted(union, key=lambda key: normalize(render_reference(union[key]))):
        ref = union[identity]
        parents = ", ".join(sorted(cited_by[identity]))
        lines.append(f"- {render_reference(ref)} — cited by direct seed(s): {parents}")
    lines.append("")

    lines.append("## Unresolved direct seeds")
    lines.append("")
    if not unresolved:
        lines.append("None.")
    else:
        for key, data in unresolved.items():
            seed = data["seed"]
            diagnostic = json.dumps(data["diagnostic"], ensure_ascii=False)
            lines.append(
                f"- **{key}** — {seed['authors']} ({seed['year']}), "
                f"*{seed['title']}*. Diagnostic: {diagnostic}"
            )
    lines.append("")

    missing_deposits = [
        key for key, item in resolved.items() if not (item.get("reference") or [])
    ]

    report = {
        "metadata_source": "Crossref",
        "seed_count": len(seeds),
        "resolved_direct_count": len(resolved),
        "unresolved_direct_count": len(unresolved),
        "direct_with_deposited_references": (
            len(resolved) - len(missing_deposits)
        ),
        "direct_without_deposited_references": missing_deposits,
        "unique_second_hop_reference_count": len(union),
        "resolved": {
            key: {
                "doi": item.get("DOI"),
                "title": work_title(item),
                "publication_year": work_year(item),
                "reference_count": len(item.get("reference") or []),
                "diagnostic": diagnostics[key],
            }
            for key, item in resolved.items()
        },
        "unresolved": unresolved,
    }

    return "\n".join(lines), report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seeds", type=Path, default=DEFAULT_SEEDS)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--pause", type=float, default=0.40)
    args = parser.parse_args()

    seeds = read_seeds(args.seeds)
    markdown, report = build(seeds, CrossrefClient(pause=args.pause))
    args.output.write_text(markdown + "\n", encoding="utf-8")
    args.report.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    print(
        f"wrote {args.output} and {args.report}: "
        f"{report['resolved_direct_count']}/{report['seed_count']} direct seeds resolved; "
        f"{report['unique_second_hop_reference_count']} unique second-hop citations",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
