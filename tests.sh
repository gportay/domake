#!/bin/bash
#
# Copyright (c) 2017-2019 Gaël PORTAY
#
# SPDX-License-Identifier: MIT
#

set -e

run() {
	id=$((id+1))
	test="#$id: $@"
	echo -e "\e[1mRunning $test...\e[0m"
}

ok() {
	ok=$((ok+1))
	echo -e "\e[1m$test: \e[32m[OK]\e[0m"
}

ko() {
	ko=$((ko+1))
	echo -e "\e[1m$test: \e[31m[KO]\e[0m"
	if [ -n "$EXIT_ON_ERROR" ]; then
		exit 1
	fi
}

fix() {
	fix=$((fix+1))
	echo -e "\e[1m$test: \e[34m[FIX]\e[0m"
}

bug() {
	bug=$((bug+1))
	echo -e "\e[1m$test: \e[33m[BUG]\e[0m"
}

result() {
	if [ -n "$ok" ]; then
		echo -e "\e[1m\e[32m$ok test(s) succeed!\e[0m"
	fi

	if [ -n "$fix" ]; then
		echo -e "\e[1m\e[34m$fix test(s) fixed!\e[0m" >&2
	fi

	if [ -n "$bug" ]; then
		echo -e "\e[1mWarning: \e[33m$bug test(s) bug!\e[0m" >&2
	fi

	if [ -n "$ko" ]; then
		echo -e "\e[1mError: \e[31m$ko test(s) failed!\e[0m" >&2
		exit 1
	fi
}

PATH="$PWD:$PATH"
trap result 0

export -n DOCKER
export -n DOSHELL
export -n DOSH_DOCKERFILE
export -n DOSH_DOCKER_BUILD_EXTRA_OPTS
export -n DOSH_DOCKER_RMI_EXTRA_OPTS
export -n DOSH_DOCKER_RUN_EXTRA_OPTS
export -n DOSH_DOCKER_EXEC_EXTRA_OPTS

run "Test option --help"
if domake --help | \
   grep '^Usage: '
then
	ok
else
	ko
fi
echo

run "Test option --version"
if domake --version | \
   grep -E '^([0-9a-zA-Z]+)(\.[0-9a-zA-Z]+)*$'
then
	ok
else
	ko
fi
echo

run "Test default target with (Makefile from stdin)"
if echo -e "all:\n\t@cat /etc/os*release" | \
   domake "$@" -f - | tee /dev/stderr | \
   grep -q 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"'
then
	ok
else
	ko
fi
echo

run "Test option -F with relative path (Makefile from stdin)"
if ( echo -e "all:\n\t@cat /etc/os*release" | \
     domake "$@" -f - -F Dockerfile.fedora | tee /dev/stderr | \
     grep -q 'PRETTY_NAME="Fedora 25 (Twenty Five)' )
then
	ok
else
	ko
fi
echo

run "Test option -C with relative path (Makefile from stdin)"
if ( cd .. && dir="${OLDPWD##*/}" && \
     echo -e "all:\n\t@cat /etc/os*release" | \
     domake "$@" -f - -C "$dir" | tee /dev/stderr | \
     grep -q 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"' )
then
	ok
else
	ko
fi
echo

run "Test option -C with absolute path (Makefile from stdin)"
if ( cd /tmp && dir="$OLDPWD" && \
     echo -e "all:\n\t@cat /etc/os*release" | \
     domake "$@" -f - -C "$dir" | tee /dev/stderr | \
     grep -q 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"' )
then
	ok
else
	ko
fi
echo

run "Test option --shell SHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/zsh domake "$@" -f - -F Dockerfile.alpine --shell /bin/sh | tee /dev/stderr | \
     grep -q 'SHELL=/bin/sh' )
then
	ok
else
	ko
fi
echo

run "Test overriding existent \$DOSHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/ash domake "$@" -f - -F Dockerfile.alpine | tee /dev/stderr | \
     grep -q 'SHELL=/bin/ash' )
then
	ok
else
	ko
fi
echo

run "Test overriding nonexistent \$DOSHELL and option --shell SHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/zsh domake "$@" -f - -F Dockerfile.alpine --shell /bin/sh | tee /dev/stderr | \
     grep -q 'SHELL=/bin/sh' )
then
	ok
else
	ko
fi
echo

run "Test overriding existent \$DOSHELL in command line argument with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     domake "$@" -f - -F Dockerfile.alpine DOSHELL=/bin/ash | tee /dev/stderr | \
     grep -q 'SHELL=/bin/ash' )
then
	ok
else
	ko
fi
echo

run "Test \$DOCKER environment variable"
if ( id="$(dosh --tag)"; \
     echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOCKER="echo docker" domake "$@" -f - --no-print-directory DOCKER='echo docker' | tee /dev/stderr | \
     diff - <(echo "\
exec --user ${GROUPS[0]}:${GROUPS[0]} --workdir $PWD \
run /bin/sh --volume $PWD:$PWD --user $UID:${GROUPS[0]} --interactive --workdir $PWD --env DOSHLVL=1 --entrypoint /bin/sh $id -c echo SHELL=\$0
rm -f run --detach --volume $PWD:$PWD --user $UID:${GROUPS[0]} --interactive --workdir $PWD --env DOSHLVL=1 --entrypoint /bin/sh $id"
))
then
	ok
else
	ko
fi
echo
