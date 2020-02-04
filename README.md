# Docker Make

## NAME

[domake](domake.1.adoc) - maintain program dependencies running commands in
container

## DESCRIPTION

[domake](domake) runs on top of *make(1)* using [dosh(1)][1] as default _shell_.

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

	$ sudo make install

Traditional variables *DESTDIR* and *PREFIX* can be overridden

	$ sudo PREFIX=/opt/domake make install

or

	$ DESTDIR=$PWD/pkg PREFIX=/usr make install

## LINKS

Check for [man-pages](domake.1.adoc) and its [examples](domake.1.adoc#examples).

Enjoy!

## BUGS

Report bugs at *https://github.com/gportay/domake/issues*

## AUTHOR

Written by Gaël PORTAY *gael.portay@gmail.com*

## COPYRIGHT

Copyright (c) 2017-2018, 2020 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the MIT License.

[1]: https://www.github.com/gportay/dosh/blob/master/dosh.1.adoc
