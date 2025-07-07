# Maintainer: Gaël PORTAY <gael.portay@gmail.com>

pkgname=(domake domake-docker-make)
pkgver=1
pkgrel=1
pkgdesc='Docker make'
arch=(any)
url=https://github.com/gportay/domake
license=(LGPL-2.1-or-later)
depends=(bash)
makedepends=(asciidoctor bash-completion)
checkdepends=(shellcheck)
source=("domake-$pkgver.tar.gz::https://github.com/gportay/domake/archive/$pkgver.tar.gz")
sha256sums=(bc93dc89527e52d25f6533924e24a961787e6efbd7305ea92615458f5e3fe30e)
validpgpkeys=(8F3491E60E62695ED780AC672FA122CA0501CA71)

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
	optdepends+=(domake-docker-make)

	cd "domake-$pkgver"
	make DESTDIR="$pkgdir" PREFIX="/usr" install install-doc install-bash-completion
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/domake/LICENSE"
}

package_domake-docker-make() {
	pkgdesc='Docker CLI plugin for domake'
	depends+=(domake)

	cd "domake-$pkgver"
	make DESTDIR="$pkgdir/" PREFIX="/usr" install-cli-plugin
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/domake-docker-make/LICENSE"
}
