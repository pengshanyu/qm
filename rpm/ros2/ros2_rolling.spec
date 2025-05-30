%global debug_package %{nil}

%define qm_sysconfdir %{_sysconfdir}/qm

Name: qm-ros2
Version: %{version}
Release: 1%{?dist}
Summary: Subpackage container for quadlet container to ROS2 Rolling environment
License: GPL-2.0-only
URL: https://github.com/containers/qm
Source0: %{url}/archive/qm-ros2-%{version}.tar.gz

BuildArch: noarch
Requires: qm >= %{version}

%description
This subpackage provides a containerized ROS2 Rolling environment within the
Quality Management (QM) system. It enables ROS2 applications to run in isolated
containers managed by Podman and systemd within the QM environment.

%prep
%autosetup -Sgit -n qm-ros2-%{version}

%build
# No special build requirements for ROS2 Rolling container

%install
# Create the necessary directory structure
install -d %{buildroot}%{qm_sysconfdir}/containers/systemd

# Install the ROS2 Rolling container file
install -m 644 %{_builddir}/qm-ros2-%{version}/subsystems/ros2/etc/containers/systemd/ros2.container \
      %{buildroot}%{qm_sysconfdir}/containers/systemd/ros2.container


%files
%license LICENSE
%doc README.md SECURITY.md
%{qm_sysconfdir}/containers/systemd/ros2.container


%changelog
* Fri Jul 21 2023 RH Container Bot <rhcontainerbot@fedoraproject.org> - 0.6.8-1
- Initial release of qm-ros2
