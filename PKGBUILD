# Maintainer: Gaël PORTAY <gael.portay@gmail.com>

pkgname=domake
pkgver=1
pkgrel=1
pkgdesc='Docker make'
arch=('any')
url="https://github.com/gportay/$pkgname"
license=('LGPL')
depends=('dosh')
makedepends=('asciidoctor')
checkdepends=('shellcheck')
source=("https://github.com/gportay/$pkgname/archive/$pkgver.tar.gz")
sha256sums=('bc93dc89527e52d25f6533924e24a961787e6efbd7305ea92615458f5e3fe30e')
validpgpkeys=('8F3491E60E62695ED780AC672FA122CA0501CA71')

build() {
	cd "$pkgname-$pkgver"
	make doc
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir" PREFIX="/usr" install install-doc install-bash-completion
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
