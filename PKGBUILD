# Maintainer: Gaël PORTAY <gael.portay@gmail.com>

pkgname=domake
pkgver=master
pkgrel=1
pkgdesc='Docker make'
arch=('any')
url='https://github.com/gportay/$pkgname'
license=('MIT')
depends=('docker' 'dosh')
makedepends=('asciidoctor')
checkdepends=('shellcheck')
source=("https://github.com/gportay/$pkgname/archive/$pkgver.tar.gz")
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
	install -D -m 755 domake "$pkgdir/usr/bin/domake"
	install -D -m 644 domake.1.gz "$pkgdir/usr/share/man/man1/domake.1.gz"
	install -D -m 644 bash-completion "$pkgdir/usr/share/bash-completion/completions/domake"
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
