#
# Copyright (c) 2017-2020, 2023 Gaël PORTAY
#
# SPDX-License-Identifier: MIT
#

PREFIX ?= /usr/local

.PHONY: all
all:
	@eval $$(cat /etc/os*release); echo $$NAME

.PHONY: doc
doc: domake.1.gz

.PHONY: install-all
install-all: install install-doc install-bash-completion install-cli-plugin

.PHONY: install
install:
	install -D -m 755 domake $(DESTDIR)$(PREFIX)/bin/domake

.PHONY: install-doc
install-doc:
	install -D -m 644 domake.1.gz $(DESTDIR)$(PREFIX)/share/man/man1/

.PHONY: install-bash-completion
install-bash-completion:
	completionsdir=$${BASHCOMPLETIONSDIR:-$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                                                    --variable=completionsdir \
	                                                    bash-completion)}; \
	if [ -n "$$completionsdir" ]; then \
		install -D -m 644 bash-completion $(DESTDIR)$$completionsdir/domake; \
	fi

.PHONY: install-cli-plugin
install-cli-plugin: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
install-cli-plugin:
	install -D -m 755 support/docker-make $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-make

.PHONY: uninstall
uninstall: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/domake
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/domake.1.gz
	rm -Rf $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-make
	completionsdir=$${BASHCOMPLETIONSDIR:-$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                             --variable=completionsdir \
	                             bash-completion)}; \
	if [ -n "$$completionsdir" ]; then \
		rm -f $(DESTDIR)$$completionsdir/domake; \
	fi

.PHONY: user-install-all
user-install-all: user-install user-install-doc user-install-bash-completion user-install-cli-plugin

user-install user-install-doc user-install-bash-completion user-install-cli-plugin user-uninstall:
user-%:
	$(MAKE) $* PREFIX=$$HOME/.local BASHCOMPLETIONSDIR=$$HOME/.local/share/bash-completion/completions DOCKERLIBDIR=$$HOME/.docker

.PHONY: ci
ci: export EXIT_ON_ERROR = 1
ci: check coverage

.PHONY: test tests
test tests:
	@./tests.bash

.PHONY: check
check: domake
	shellcheck $^

.PHONY: coverage
coverage:
	kcov $(CURDIR)/$@ --include-path=domake $(CURDIR)/tests.bash

ifneq (,$(BUMP_VERSION))
.SILENT: bump
.PHONY: bump
bump: export GPG_TTY ?= $(shell tty)
bump:
	! git tag | grep "^$(BUMP_VERSION)$$"
	old="$$(bash domake --version)"; \
	sed -e "/^VERSION=/s,$$old,$(BUMP_VERSION)," -i domake; \
	sed -e "/^:man source:/s,$$old,$(BUMP_VERSION)," -i domake.1.adoc; \
	sed -e "/^pkgver=/s,$$old,$(BUMP_VERSION)," -e "/^pkgrel=/s,=.*,=1," -i PKGBUILD
	git commit --gpg-sign domake domake.1.adoc PKGBUILD --patch --message "domake: version $(BUMP_VERSION)"
	git tag --sign --annotate --message "domake-$(BUMP_VERSION)" "$(BUMP_VERSION)"
else
.SILENT: bump-major
.PHONY: bump-major
bump-major:
	old="$$(bash domake --version)"; \
	new="$$(($${old%.*}+1))"; \
	$(MAKE) bump "BUMP_VERSION=$$new"

.SILENT: bump-minor
.PHONY: bump-minor
bump-minor:
	old="$$(bash domake --version)"; \
	if [ "$${old%.*}" = "$$old" ]; then old="$$old.0"; fi; \
	new="$${old%.*}.$$(($${old##*.}+1))"; \
	$(MAKE) bump "BUMP_VERSION=$$new"

.SILENT: bump
.PHONY: bump
bump: bump-major
endif

.PHONY: bump-PKGBUILD
bump-PKGBUILD: updpkgsums
	git commit PKGBUILD --patch --message "PKGBUILD: update release $$(bash domake --version) checksum"

.PHONY: commit-check
commit-check:
	git rebase -i -x "$(MAKE) check && $(MAKE) tests"

.PHONY: clean
clean:
	rm -f domake.1.gz
	rm -f PKGBUILD.tmp *.tar.gz src/*.tar.gz *.pkg.tar.xz \
	   -R src/dosh-*/ pkg/domake-*/ domake-git/
	rm -Rf coverage/

.PHONY: updpkgsums
updpkgsums:
	updpkgsums

.PHONY: aur
aur:
	makepkg --force --syncdeps

.PHONY: aur-git
aur-git: PKGBUILD.tmp
	makepkg --force --syncdeps -p $^

PKGBUILD.tmp: PKGBUILD-git
	cp $< $@

%.1: %.1.adoc
	asciidoctor -b manpage -o $@ $<

%.gz: %
	gzip -c $< >$@

