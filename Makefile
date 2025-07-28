#
# Copyright 2017-2020,2023-2025 Gaël PORTAY
#
# SPDX-License-Identifier: LGPL-2.1-or-later
#

PREFIX ?= /usr/local
VERSION ?= $(shell bash domake --version)

.PHONY: all
all:
	@eval $$(cat /etc/os*release); echo $$NAME
	@uname -m

.PHONY: doc
doc: domake.1.gz

.PHONY: install-all
install-all: install install-doc install-bash-completion install-cli-plugin

.PHONY: install
install:
	install -D -m 755 domake $(DESTDIR)$(PREFIX)/bin/domake

.PHONY: install-doc
install-doc:
	install -D -m 644 domake.1.gz $(DESTDIR)$(PREFIX)/share/man/man1/domake.1.gz

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
	rm -f $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-make
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
ci: check tests

.PHONY: test tests
test tests:
	@./tests.bash

.PHONY: check
check: domake
	shellcheck $^

ifneq (,$(BUMP_VERSION))
.SILENT: bump
.PHONY: bump
bump: export GPG_TTY ?= $(shell tty)
bump:
	! git tag | grep "^$(BUMP_VERSION)$$"
	old="$$(bash domake --version)"; \
	sed -e "/^VERSION=/s,$$old,$(BUMP_VERSION)," -i domake; \
	sed -e "/^:man source:/s,$$old,$(BUMP_VERSION)," -i domake.1.adoc; \
	sed -e "1idomake ($(BUMP_VERSION)) unstable; urgency=medium\n\n  * New release.\n\n -- $(shell git config user.name) <$(shell git config user.email)>  $(shell date --rfc-email)" -i debian/changelog; \
	sed -e "/^Version:/s,$$old,$(BUMP_VERSION)," -i domake.spec; \
	sed -e "/%changelog/a* $(shell date "+%a %b %d %Y") $(shell git config user.name) <$(shell git config user.email)> - $(BUMP_VERSION)-1" -i domake.spec; \
	sed -e "/^pkgver=/s,$$old,$(BUMP_VERSION)," -e "/^pkgrel=/s,=.*,=1," -i PKGBUILD
	git commit --gpg-sign domake domake.1.adoc debian/changelog domake.spec PKGBUILD --patch --message "domake: version $(BUMP_VERSION)"
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

.PHONY: commit-check
commit-check:
	git rebase -i -x "$(MAKE) check && $(MAKE) tests"

.PHONY: clean
clean:
	rm -f domake.1.gz
	rm -f debian/files debian/debhelper-build-stamp debian/*.substvars \
	   -R debian/.debhelper/ debian/tmp/ \
	      debian/domake/ debian/domake-docker-make/
	rm -f *.tar.gz src/*.tar.gz *.pkg.tar* \
	   -R src/domake-*/ pkg/domake-*/ domake-git/
	rm -f rpmbuild/SOURCES/*.tar.gz rpmbuild/SPECS/*.spec \
	      rpmbuild/SRPMS/*.rpm rpmbuild/RPMS/*/*.rpm

%.1: %.1.adoc
	asciidoctor -b manpage -o $@ $<

%.gz: %
	gzip -c $< >$@

.PHONY: deb
deb: PATH:=$(CURDIR):$(PATH)
deb: SHELL=dosh
deb: export DOSH_DOCKERFILE=Dockerfile.deb
deb:
	dpkg-buildpackage -us -uc
	lintian ../domake*.dsc ../domake*.deb

.PHONY: pkg
pkg: PATH:=$(CURDIR):$(PATH)
pkg: SHELL=dosh
pkg: export DOSH_DOCKERFILE=Dockerfile.pkg
pkg:
	makepkg --force --skipchecksums
	shellcheck --shell=bash --exclude=SC2034,SC2154,SC2164 PKGBUILD*
	namcap PKGBUILD* domake*.pkg.tar*

.PHONY: rpm
rpm: PATH:=$(CURDIR):$(PATH)
rpm: SHELL=dosh
rpm: export DOSH_DOCKERFILE=Dockerfile.rpm
rpm:
	cd ~/rpmbuild/SPECS
	rpmbuild --undefine=_disable_source_fetch -ba domake.spec
	rpmlint ~/rpmbuild/SPECS/domake.spec ~/rpmbuild/SRPMS/domake*.rpm ~/rpmbuild/RPMS/domake*.rpm

.PHONY: sources
sources: domake-$(VERSION).tar.gz rpmbuild/SOURCES/v$(VERSION).tar.gz

rpmbuild/SOURCES/$(VERSION).tar.gz:
rpmbuild/SOURCES/%.tar.gz:
	git archive --prefix domake-$*/ --format tar.gz --output $@ HEAD

domake-$(VERSION).tar.gz:
%.tar.gz:
	git archive --prefix $*/ --format tar.gz --output $@ HEAD
