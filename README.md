# Docker Make

## NAME

[domake](domake.1.adoc) - maintain program dependencies running commands in
container

## DESCRIPTION

[domake](domake) runs on top of *make(1)* using [dosh(1)] as default _shell_.

## DOWNLOAD

Give it a try right now by fetching your own copy!

*Version* | *Checksum* (\*)                                                  |
--------- | ---------------------------------------------------------------- |
[1]       | bc93dc89527e52d25f6533924e24a961787e6efbd7305ea92615458f5e3fe30e |

\*: Note that hashes are subject to change as GitHub might update tarball
generation.

## DOCUMENTATION

Using *domake(1)* and _Makefile_

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

Check for [man-pages](domake.1.adoc) and its [examples](domake.1.adoc#examples).

Enjoy!

## BUGS

Report bugs at *https://github.com/gportay/domake/issues*

## AUTHOR

Written by Gaël PORTAY *gael.portay@gmail.com*

## COPYRIGHT

Copyright 2017-2018,2020,2023-2024 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 2.1 of the License, or (at your option) any
later version.

[dosh(1)]: https://www.github.com/gportay/dosh/blob/master/dosh.1.adoc
[1]: https://github.com/gportay/domake/archive/1.tar.gz
