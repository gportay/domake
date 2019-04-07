#
# Copyright (c) 2017-2019 Gaël PORTAY
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
install-all: install install-doc install-bash-completion

.PHONY: install
install:
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 755 domake $(DESTDIR)$(PREFIX)/bin/

.PHONY: install-doc
install-doc:
	install -d $(DESTDIR)$(PREFIX)/share/man/man1/
	install -m 644 domake.1.gz $(DESTDIR)$(PREFIX)/share/man/man1/

.PHONY: install-bash-completion
install-bash-completion:
	completionsdir=$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                             --variable=completionsdir \
	                             bash-completion); \
	if [ -n "$$completionsdir" ]; then \
		install -d $(DESTDIR)$$completionsdir/; \
		install -m 644 bash-completion $(DESTDIR)$$completionsdir/domake; \
	fi

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/domake
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/domake.1.gz
	completionsdir=$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                             --variable=completionsdir \
	                             bash-completion); \
	if [ -n "$$completionsdir" ]; then \
		rm -f $(DESTDIR)$$completionsdir/domake; \
	fi

.PHONY: user-install-all
user-install-all: user-install user-install-doc user-install-bash-completion

user-install user-install-doc user-install-bash-completion user-uninstall:
user-%:
	$(MAKE) $* PREFIX=$$HOME/.local

.PHONY: tests
tests:
	@./tests.sh

.PHONY: check
check: domake
	shellcheck $^

ifneq (,$(BUMP_VERSION))
.SILENT: bump
bump:
	! git tag | grep "$(BUMP_VERSION)"
	old="$$(bash domake --version)"; \
	sed -e "/^VERSION=/s,$$old,$(BUMP_VERSION)," -i domake; \
	sed -e "/^:man source:/s,$$old,$(BUMP_VERSION)," -i domake.1.adoc; \
	sed -e "/^pkgver=/s,$$old,$(BUMP_VERSION)," -e "/^pkgrel=/s,=.*,=1," -i PKGBUILD
	git commit domake domake.1.adoc PKGBUILD --patch --message "domake: version $(BUMP_VERSION)"
	git tag --annotate --message "domake-$(BUMP_VERSION)" "$(BUMP_VERSION)"
else
.SILENT: bump-major
bump-major:
	old="$$(bash domake --version)"; \
	new="$$(($${old%.*}+1)).0"; \
	$(MAKE) bump "BUMP_VERSION=$$new"

.SILENT: bump-minor
bump-minor:
	old="$$(bash domake --version)"; \
	new="$${old%.*}.$$(($${old##*.}+1))"; \
	$(MAKE) bump "BUMP_VERSION=$$new"

.SILENT: bump
bump: bump-minor
endif

.PHONY: commit-check
commit-check:
	git rebase -i -x "$(MAKE) check && $(MAKE) tests"

.PHONY: bump-PKGBUILD
bump-PKGBUILD: aur
	cp PKGBUILD.aur PKGBUILD
	git commit PKGBUILD --patch --message "PKGBUILD: update release $$(bash domake --version) checksum"

.PHONY: clean
clean:
	rm -f domake.1.gz
	rm -f PKGBUILD.aur PKGBUILD.devel *.tar.gz src/*.tar.gz *.pkg.tar.xz \
	   -R src/domake-*/ pkg/domake/

.PHONY: aur
aur: PKGBUILD.aur
	makepkg --force --syncdeps -p $^

PKGBUILD.aur: PKGBUILD
	cp $< $@.tmp
	makepkg --nobuild --nodeps --skipinteg -p $@.tmp
	md5sum="$$(makepkg --geninteg -p $@.tmp)"; \
	sed -e "/md5sums=/d" \
	    -e "/source=/a$$md5sum" \
	    -i $@.tmp
	mv $@.tmp $@

.PHONY: devel
devel: PKGBUILD.devel
	makepkg --force --syncdeps -p $^

PKGBUILD.devel: PKGBUILD
	sed -e "/source=/d" \
	    -e "/md5sums=/d" \
	    -e "/build() {/,/^}$$/s,\$$srcdir/\$$pkgname-\$$pkgver,\$$startdir,g" \
	    -e "/package() {/,/^}$$/s,\$$srcdir/\$$pkgname-\$$pkgver,\$$startdir,g" \
	    -e "/pkgver=/apkgver() { printf \"\$$(bash domake --version)r%s.%s\" \"\$$(git rev-list --count HEAD)\" \"\$$(git rev-parse --short HEAD)\"; }" \
	       $< >$@

%.1: %.1.adoc
	asciidoctor -b manpage -o $@ $<

%.gz: %
	gzip -c $^ >$@

