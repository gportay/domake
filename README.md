# Docker Make

[![Deploy Arch Linux package to GitHub Release](https://github.com/gportay/domake/actions/workflows/pkg-package.yml/badge.svg)](https://github.com/gportay/domake/actions/workflows/pkg-package.yml)
[![Deploy Debian package to GitHub Release](https://github.com/gportay/domake/actions/workflows/deb-package.yml/badge.svg)](https://github.com/gportay/domake/actions/workflows/deb-package.yml)
[![Deploy RPM package to GitHub Release](https://github.com/gportay/domake/actions/workflows/rpm-package.yml/badge.svg)](https://github.com/gportay/domake/actions/workflows/rpm-package.yml)

[![Packaging status](https://repology.org/badge/vertical-allrepos/domake.svg)](https://repology.org/project/domake/versions)

## TL;DR;

[domake][domake(1)] is a bash script providing a make CLI to *docker-run(1)*.

It runs every shell command of the Makefile in a docker shell with cwd bind
mounted to the container built using the Dockerfile.

One think `domake` does...

	docker run --detach [--tty] [--interactive] "--volume=$PWD:$PWD:rw" "--user=$USER" "--entry-point=$SHELL" IMAGE
	make SHELL="docker exec [--tty] [--interactive] CONTAINER /bin/sh"
	docker kill CONTAINER

... with a few more magic!

## NAME

[domake](domake.1.adoc) - maintain program dependencies running commands in
container

## DESCRIPTION

[domake](domake) runs on top of *make(1)* using [dosh(1)] as default _shell_.

## DOCUMENTATION

Build the documentation using *domake(1)* and _Makefile_

	$ domake doc
	sha256:ced062433e33
	asciidoctor -b manpage -o domake.1 domake.1.adoc
	gzip -c domake.1 >domake.1.gz
	rm domake.1
	83727c98a60a9648b20d127c53526e785a051cef2235702071b8504bb1bdca59

## INSTALL

Run the following command to install *domake(1)*

To your home directory

	$ make user-install

Or, to your system

	$ sudo make install

Traditional variables *DESTDIR* and *PREFIX* can be overridden

	$ sudo make install PREFIX=/opt/domake

Or

	$ make install DESTDIR=$PWD/pkg PREFIX=/usr

## LINKS

Check for [man-pages][domake(1)] and its [examples].

Enjoy!

## PATCHES

Submit patches at *https://github.com/gportay/domake/pulls*

## BUGS

Report bugs at *https://github.com/gportay/domake/issues*

## AUTHOR

Written by Gaël PORTAY *gael.portay@gmail.com*

## COPYRIGHT

Copyright 2017-2018,2020,2023-2025 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 2.1 of the License, or (at your option) any
later version.

[domake(1)]: domake.1.adoc
[dosh(1)]: https://www.github.com/gportay/dosh/blob/master/dosh.1.adoc
[examples]: domake.1.adoc#examples
