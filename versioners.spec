%define __os_install_post %{nil}
Summary: Automatic Versioning Tools
Name: versioners
Version: %{version}
Release: %{release}
License: Andrew Kesterson
Vendor: Andrew Kesterson
Packager: Andrew Kesterson <andrew@aklabs.net>
Group: Development Tools
Provides: %{name}
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
Source: %{name}-%{version}-%{release}.tar.gz

Requires: bash

%description

%install
mkdir -p %{buildroot}/usr/src
tar -zxvf %{_sourcedir}/%{name}-%{version}-%{release}.tar.gz
cd %{name}-%{version}-%{release}
PREFIX=%{buildroot} make install
PREFIX=%{buildroot} make MANIFEST
cp MANIFEST /tmp/

%files -f /tmp/MANIFEST
