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

	install -d "$pkgdir/usr/bin/"
	install -m 755 domake "$pkgdir/usr/bin/"
	install -d "$pkgdir/usr/share/man/man1/"
	install -m 644 domake.1.gz "$pkgdir/usr/share/man/man1/"
	install -d "$pkgdir/usr/share/bash-completion/completions"
	install -m 644 bash-completion \
	           "$pkgdir/usr/share/bash-completion/completions"
	install -d "$pkgdir/usr/share/licenses/$pkgname/"
	install -m 644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/"
}
