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
source=("https://github.com/gportay/$pkgname/archive/$pkgver.tar.gz")

build() {
	cd "$srcdir/$pkgname-$pkgver"
	make doc
}

package() {
	cd "$srcdir/$pkgname-$pkgver"
	install -D -m 755 domake "$pkgdir/usr/bin/domake"
	install -D -m 644 domake.1.gz "$pkgdir/usr/share/man/man1/domake.1.gz"
	install -D -m 644 bash-completion "$pkgdir/usr/share/bash-completion/completions/domake"
	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
