#!/usr/bin/env -S DOSH_DOCKERFILE=Dockerfile.deb parent=1 dosh
set -e
dpkg-buildpackage -us -uc "$@"
lintian ../domake*.dsc ../domake*.deb
