.PHONY: tar_tracked
REPO := $(notdir $(shell git rev-parse --show-toplevel))
DATE := $(shell date +%Y%m%d)
TAR_EDITED := $(REPO)-$(DATE)-tracked.tar.gz

tar_tracked:
	@git ls-files -z \
	| tar -cf - --null --no-recursion -T - --transform 's|^|$(REPO)\|' \
	| gzip > "$(TAR_EDITED)"
	@echo "Wrote $(TAR_EDITED)"
