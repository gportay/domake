Name:           domake
Version:        1
Release:        1%{?dist}
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
%make_install PREFIX=/usr DOCKERLIBDIR=%{_libdir}/docker install-all


%files
%license LICENSE
%doc README.md
%{_bindir}/domake
%{_datadir}/bash-completion/completions/domake
%{_datadir}/man/man1/domake.1.gz


%files docker-make
%{_libdir}/docker/cli-plugins/docker-make

%changelog
* Mon Jul 07 2025 Gaël PORTAY <gael.portay@gmail.com> - 1-1
- Initial release.
