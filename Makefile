# Generated compiler build rules come from the pinned canonical package.
# Local applications and this adapter may add targets without editing them.
include deps/idric-dex/Makefile

.PHONY: canonical-pin legacy-branch-separation
canonical-pin:
	$(GREASE) deps/idric-dex/check-pin.grease "$(CURDIR)"

check driver dex-test: canonical-pin

branch-separation: canonical-pin legacy-branch-separation

legacy-branch-separation:
	tests/dex/branch-separation-self-test.sh
	tests/dex/branch-separation.sh
