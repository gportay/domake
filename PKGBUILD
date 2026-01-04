# Maintainer: Gaël PORTAY <gael.portay@gmail.com>

pkgname=(domake domake-linux-platforms)
pkgver=3
pkgrel=1
pkgdesc='Docker make'
arch=(any)
url=https://github.com/gportay/domake
license=(LGPL-2.1-or-later)
depends=(bash)
makedepends=(asciidoctor bash-completion)
checkdepends=(shellcheck)
source=("domake-$pkgver.tar.gz::https://github.com/gportay/domake/archive/$pkgver.tar.gz")
sha256sums=(SKIP)
validpgpkeys=(8F3491E60E62695ED780AC672FA122CA0501CA71)
changelog=CHANGELOG.md

build() {
	cd "domake-$pkgver"
	make domake.1.gz
}

check() {
	cd "domake-$pkgver"
	make -k check
}

package_domake() {
	depends+=(dosh)

	cd "domake-$pkgver"
	make DESTDIR="$pkgdir" PREFIX="/usr" install install-doc install-bash-completion install-docker-cli-plugin
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/domake/LICENSE"
}

package_domake-linux-platforms() {
	pkgdesc='Docker shell for linux platforms'
	depends+=(domake)

	cd "domake-$pkgver"
	make DESTDIR="$pkgdir" PREFIX="/usr" install-linux-platforms
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/domake-linux-platforms/LICENSE"
}
