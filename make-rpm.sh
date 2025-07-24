#!/usr/bin/env -S DOSH_DOCKERFILE=Dockerfile.rpm DOSH_DOCKER_RUN_EXTRA_OPTS="--volume ${PWD}/rpmbuild:${HOME}/rpmbuild --volume ${PWD}/domake.spec:${HOME}/rpmbuild/SPECS/domake.spec" dosh
set -e
rpmdev-setuptree
cd ~/rpmbuild/SPECS
rpmbuild --undefine=_disable_source_fetch -ba domake.spec "$@"
rpmlint ~/rpmbuild/SPECS/domake.spec ~/rpmbuild/SRPMS/domake*.rpm ~/rpmbuild/RPMS/domake*.rpm
