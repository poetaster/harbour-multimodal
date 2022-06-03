Name:       harbour-multimodal

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}


Summary:        multimodal
Version:        0.87
Release:        1
License:        MIT
Source0:        %{name}-%{version}.tar.bz2
BuildArch:  	noarch
Group:          Qt/Qt

Requires:   	sailfishsilica-qt5 >= 0.10.9
Requires:   	pyotherside-qml-plugin-python3-qt5
Requires:   	libsailfishapp-launcher
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Public Transit App

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
sed -i 's/CLIENT-ID/fb21976dbed2d0ded50a246086440da2/' %{_datadir}/%{name}/src/dbahn_client/dbahn_client.py
sed -i 's/API-ID/fde407a46b1014b445c162466a7a8489/' %{_datadir}/%{name}/src/dbahn_client/dbahn_client.py
sed -i 's/API-ID/8650ba70-f8e8-4c44-af6f-49b1a9cc697c/' %{_datadir}/%{name}/src/ldbws_client/ldbws_client.py
sed -i 's/OCP-AP/2682038d1d2e4d33bd114361c6dd9c58/' %{_datadir}/%{name}/src/tfgm_client/tfgm_client.py

%changelog
* Sat May 29 2021  anarchy_in_the_uk
- 0.1 r1 release

