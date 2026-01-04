Name:           domake
Version:        3
Release:        1
Summary:        Maintain program dependencies running commands in container

License:        LGPL-2.1-or-later
URL:            https://github.com/gportay/%{name}
Source0:        https://github.com/gportay/%{name}/archive/%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  asciidoctor
BuildRequires:  make
BuildRequires:  shellcheck
BuildRequires:  pkgconfig(bash-completion)
Requires:       bash
Requires:       docker

%description
domake(1) runs on top of make(1) using dosh(1) as default shell.


%global debug_package %{nil}

%package  linux-amd64
Requires: dosh
Summary:  Docker make for linux/amd64 platform

%description linux-amd64
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  linux-arm64
Requires: dosh
Summary:  Docker make for linux/arm64 platform

%description linux-arm64
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  linux-arm
Requires: dosh
Summary:  Docker make for linux/arm platform

%description linux-arm
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  linux-ppc64le
Requires: dosh
Summary:  Docker make for linux/ppc64le platform

%description linux-ppc64le
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  linux-riscv64
Requires: dosh
Summary:  Docker make for linux/riscv64 platform

%description linux-riscv64
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  linux-s390x
Requires: dosh
Summary:  Docker make for linux/s390x platform

%description linux-s390x
domake(1) runs on top of make(1) using dosh(1) as default shell.


%package  docker-make
Requires: docker
Summary:  Docker CLI plugin for domake

%description docker-make
Docker CLI plugin for domake.


%prep
%setup -q


%check
make check


%build
%make_build domake.1.gz


%install
%make_install PREFIX=/usr DOCKERLIBDIR=%{_libdir}/docker install-all install-linux-amd64-domake install-linux-arm64-domake install-linux-arm-domake install-linux-arm-v6-domake install-linux-arm-v7-domake install-linux-ppc64le-domake install-linux-riscv64-domake install-linux-s390x-domake


%post docker-make
_libdir=$(rpm --eval '%%{_libdir}')
mkdir -p "$_libdir/docker/cli-plugins"
ln -sf ../../../../..%{_dockerlibdir}/cli-plugins/docker-bash "$_libdir/docker/cli-plugins/docker-make"


%preun docker-make
_libdir=$(rpm --eval '%%{_libdir}')
rm -f "$_libdir/docker/cli-plugins/docker-make"


%files
%license LICENSE
%doc README.md
%{_bindir}/domake
%{_datadir}/bash-completion/completions/domake
%{_datadir}/man/man1/domake.1.gz


%files linux-amd64
%{_bindir}/linux-amd64-domake


%files linux-arm64
%{_bindir}/linux-arm64-domake


%files linux-arm
%{_bindir}/linux-arm-domake
%{_bindir}/linux-arm-v6-domake
%{_bindir}/linux-arm-v7-domake


%files linux-ppc64le
%{_bindir}/linux-ppc64le-domake


%files linux-riscv64
%{_bindir}/linux-riscv64-domake


%files linux-s390x
%{_bindir}/linux-s390x-domake


%files docker-make
%{_dockerlibdir}/cli-plugins/docker-make

%changelog
* Fri Aug 01 2025 Gaël PORTAY <gael.portay@gmail.com> - 3-1
- Add --platform option to support multi-platform.
* Wed Jul 16 2025 Gaël PORTAY <gael.portay@gmail.com> - 2-1
- Rename DOCKER to DOSH_DOCKER.
- Run dosh --rm and DOSH_DOCKER from dosh 4.
- Fix argument variables containing whitespaces.
* Mon Jul 07 2025 Gaël PORTAY <gael.portay@gmail.com> - 1-1
- Initial release.
