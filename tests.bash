#!/bin/bash
#
# Copyright (c) 2017-2020,2023-2024 Gaël PORTAY
#
# SPDX-License-Identifier: MIT
#

set -e
set -o pipefail

run() {
	lineno="${BASH_LINENO[0]}"
	test="$*"
	echo -e "\e[1mRunning $test...\e[0m"
}

ok() {
	ok=$((ok+1))
	echo -e "\e[1m$test: \e[32m[OK]\e[0m"
}

ko() {
	ko=$((ko+1))
	echo -e "\e[1m$test: \e[31m[KO]\e[0m"
	reports+=("$test at line \e[1m$lineno \e[31mhas failed\e[0m!")
	if [[ $EXIT_ON_ERROR ]]
	then
		exit 1
	fi
}

fix() {
	fix=$((fix+1))
	echo -e "\e[1m$test: \e[34m[FIX]\e[0m"
	reports+=("$test at line \e[1m$lineno is \e[34mfixed\e[0m!")
}

bug() {
	bug=$((bug+1))
	echo -e "\e[1m$test: \e[33m[BUG]\e[0m"
	reports+=("$test at line \e[1m$lineno is \e[33mbugged\e[0m!")
}

result() {
	exitcode="$?"
	trap - 0

	echo -e "\e[1mTest report:\e[0m"
	for report in "${reports[@]}"
	do
		echo -e "$report" >&2
	done

	if [[ $ok ]]
	then
		echo -e "\e[1m\e[32m$ok test(s) succeed!\e[0m"
	fi

	if [[ $fix ]]
	then
		echo -e "\e[1m\e[34m$fix test(s) fixed!\e[0m" >&2
	fi

	if [[ $bug ]]
	then
		echo -e "\e[1mWarning: \e[33m$bug test(s) bug!\e[0m" >&2
	fi

	if [[ $ko ]]
	then
		echo -e "\e[1mError: \e[31m$ko test(s) failed!\e[0m" >&2
	fi

	if [[ $exitcode -ne 0 ]] && [[ $ko ]]
	then
		echo -e "\e[1;31mExited!\e[0m" >&2
	elif [[ $exitcode -eq 0 ]] && [[ $ko ]]
	then
		exit 1
	fi

	exit "$exitcode"
}

PATH="$PWD:$PATH"
trap result 0 SIGINT

export -n DOCKER
export -n DOSHELL
export -n DOSH_DOCKERFILE
export -n DOSH_DOCKER_BUILD_EXTRA_OPTS
export -n DOSH_DOCKER_RMI_EXTRA_OPTS
export -n DOSH_DOCKER_RUN_EXTRA_OPTS
export -n DOSH_DOCKER_EXEC_EXTRA_OPTS

no_doshprofile=1
no_doshrc=1

export no_doshprofile
export no_doshrc

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
   grep 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"' >/dev/null
then
	ok
else
	ko
fi
echo

run "Test option --dockerfile with relative path (Makefile from stdin)"
if ( echo -e "all:\n\t@cat /etc/os*release" | \
     domake "$@" -f - --dockerfile Dockerfile.fedora | tee /dev/stderr | \
     grep 'PRETTY_NAME="Fedora 25 (Twenty Five)' >/dev/null )
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
     grep 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"' >/dev/null )
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
     grep 'PRETTY_NAME="Ubuntu 16.04[.0-9]* LTS"' >/dev/null )
then
	ok
else
	ko
fi
echo

run "Test option --shell SHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/zsh domake "$@" -f - --dockerfile Dockerfile.alpine --shell /bin/sh | tee /dev/stderr | \
     grep 'SHELL=/bin/sh' >/dev/null )
then
	ok
else
	ko
fi
echo

run "Test overriding existent \$DOSHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/ash domake "$@" -f - --dockerfile Dockerfile.alpine | tee /dev/stderr | \
     grep 'SHELL=/bin/ash' >/dev/null )
then
	ok
else
	ko
fi
echo

run "Test overriding nonexistent \$DOSHELL and option --shell SHELL with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     DOSHELL=/bin/zsh domake "$@" -f - --dockerfile Dockerfile.alpine --shell /bin/sh | tee /dev/stderr | \
     grep 'SHELL=/bin/sh' >/dev/null )
then
	ok
else
	ko
fi
echo

run "Test overriding existent \$DOSHELL in command line argument with a busybox based distro (/bin/ash)"
if ( echo -e "all:\n\t@echo SHELL=\$\$0" | \
     domake "$@" -f - --dockerfile Dockerfile.alpine DOSHELL=/bin/ash | tee /dev/stderr | \
     grep 'SHELL=/bin/ash' >/dev/null )
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
run /bin/sh --volume $PWD:$PWD:rw --user $UID:${GROUPS[0]} --interactive --workdir $PWD --env DOSHLVL=1 --entrypoint /bin/sh $id -c echo SHELL=\$0
rm -f run --detach --volume $PWD:$PWD:rw --user $UID:${GROUPS[0]} --interactive --workdir $PWD --env DOSHLVL=1 --entrypoint /bin/sh $id"
))
then
	ok
else
	ko
fi
echo
