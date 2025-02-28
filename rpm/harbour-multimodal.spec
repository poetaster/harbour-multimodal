Name:       harbour-multimodal

# >> macros
%define _binary_payload w2.xzdio
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}


Summary:        multimodal
Version:        0.98
Release:        1
License:        MIT
URL:            https://openrepos.net/content/anarchyintheuk/multimodal
Source0:        %{name}-%{version}.tar.bz2
BuildArch:  	noarch
Group:          Qt/Qt

Requires:   	sailfishsilica-qt5 >= 0.10.9
Requires:   	pyotherside-qml-plugin-python3-qt5
Requires:   	libsailfishapp-launcher
BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Public Transit App

%if "%{?vendor}" == "chum"
PackageName: harbour-multimodal
Type: desktop-application
Categories:
 - Maps
 - Utility
 - News
DeveloperName: anarchy_in_the_uk
PackagerName: Mark Washeim (poetaster)
Custom:
 - Repo: https://github.com/poetaster/harbour-multimodal
Icon: https://raw.githubusercontent.com/poetaster/harbour-multimodal/master/screenshot-1.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/harbour-multimodal/master/screenshot-1.png
 - https://raw.githubusercontent.com/poetaster/harbour-multimodal/master/screenshot-2.png
 - https://raw.githubusercontent.com/poetaster/harbour-multimodal/master/screenshot-3.png
%endif

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5

make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files

%post
sed -i 's/CLIENT-ID/c832e0d20b3d711bd456b8dad388a7a1/' %{_datadir}/%{name}/src/dbahn_client/dbahn_client.py
sed -i 's/API-ID/5067e18b90aa7c7f6b9b45c39f867800/' %{_datadir}/%{name}/src/dbahn_client/dbahn_client.py

sed -i 's/API-ID/8650ba70-f8e8-4c44-af6f-49b1a9cc697c/' %{_datadir}/%{name}/src/ldbws_client/ldbws_client.py
sed -i 's/OCP-AP/2682038d1d2e4d33bd114361c6dd9c58/' %{_datadir}/%{name}/src/tfgm_client/tfgm_client.py

%changelog
* Sat May 29 2021  anarchy_in_the_uk
- 0.1 r1 release

