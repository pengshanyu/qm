#!/bin/bash -evx

# shellcheck source=tests/ffi/common/prepare.sh
. ../common/prepare.sh

check_var_partition(){ 
   # Prints all available block devices to make it easier to debug
   lsblk
   df -kh
   # If there is no separate /var partition this test will terminate early
   if podman exec qm findmnt /var; then
      info_message "A separate /var partition was detected on the image."
   else
      info_message "FAIL: No separate /var partition was detected on the image."
      info_message "Test terminated, it requires a separate /var disk partition for QM to run this test."
      exit 1
   fi
}

check_var_partition
disk_cleanup
prepare_test

# seccomp_file_name="/usr/share/qm/seccomp.json"
# release_id=$(grep -oP '(?<=^ID=)\w+' <<< "$(tr -d '"' < /etc/os-release)")
# if [[ "$release_id" == "centos" ]]; then
#    seccomp_file_name="/usr/share/qm/seccomp-no-rt.json"
# fi

# cat << EOF > "${DROP_IN_DIR}"/oom.conf
# [Service]
# OOMScoreAdjust=
# OOMScoreAdjust=1000

# [Container]
# PodmanArgs=
# PodmanArgs=--pids-limit=-1 --security-opt seccomp=${seccomp_file_name} --security-opt label=nested --security-opt unmask=all --memory 5G

# EOF

reload_config
prepare_images

# exec_cmd "podman exec -it qm /bin/bash -c \
#          'podman run -d --replace --name ffi-qm \
#           quay.io/centos-sig-automotive/ffi-tools:latest \
#           tail -f /dev/null'"

run_container_in_qm "ffi-qm"
exec_cmd "podman exec -it qm /bin/bash -c \
         'podman exec -it ffi-qm ./QM/file-allocate'"

#------------debug info------------
lsblk
df -kh
podman exec -it qm df -kh /var/tmp
#------------debug info------------

if ! eval "fallocate -l 2G /root/file.lock" ; then
   info_message "FAIL: No space left on device."
   podman exec -it qm /bin/bash -c 'podman  rmi -i -f --all; echo $?'
   exit 1
fi

#------------debug info------------
lsblk
df -kh
podman exec -it qm df -kh /var/tmp
#------------debug info------------
ls -lh /root/file.lock
info_message "PASS: The disk in qm is full, host is not affected."

# Calling cleanup QM directory to workaround exit code once
# /var/qm disk is full.
podman exec -it qm /bin/bash -c 'podman  rmi -i -f --all; echo $?'
