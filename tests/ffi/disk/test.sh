#!/bin/bash -evx

# shellcheck disable=SC1091

. ../common/prepare.sh

check_var_partition(){
   var_partition_name="part /var/qm"

   if stat /run/ostree-booted > /dev/null 2>&1; then
      var_partition_name="part /var"
   else
      local release_id
      release_id=$(grep -oP '(?<=^ID=)\w+' <<< "$(tr -d '"' < /etc/os-release)")
      if [[ "$release_id" == "centos" ]]; then
         var_partition_name="part /usr/lib/qm/rootfs/var"
      fi
   fi
   echo "$var_partition_name"

   if [[ "$(lsblk -o 'MAJ:MIN,TYPE,MOUNTPOINTS')" =~ ${var_partition_name} ]]; then
      info_message "A separate /var partition was detected on the image."
   else
      lsblk
      df -kh
      info_message "FAIL: No separate /var partition was detected on the image."
      info_message "Test terminated, it requires a separate /var disk partition for QM to run this test."
      exit 1
   fi
}

check_var_partition
disk_cleanup
prepare_test

cat << EOF > "${DROP_IN_DIR}"/oom.conf
[Service]
OOMScoreAdjust=
OOMScoreAdjust=1000

[Container]
PodmanArgs=
PodmanArgs=--pids-limit=-1 --security-opt seccomp=/usr/share/qm/seccomp-no-rt.json --security-opt label=nested --security-opt unmask=all --memory 5G

EOF

reload_config
prepare_images

exec_cmd "podman exec -it qm /bin/bash -c \
         'podman run -d --replace --name ffi-qm \
          quay.io/centos-sig-automotive/ffi-tools:latest \
          tail -f /dev/null'"

exec_cmd "podman exec -it qm /bin/bash -c \
         'podman exec -it ffi-qm ./QM/file-allocate'"

#------------debug info------------
podman exec -it qm df -kh /var/tmp
#------------debug info------------

if ! eval "fallocate -l 2G /root/file.lock" ; then
   info_message "FAIL: No space left on device."
   podman exec -it qm /bin/bash -c 'podman  rmi -i -f --all; echo $?'
   exit 1
fi

ls -lh /root/file.lock
info_message "PASS: The disk in qm is full, host is not affected."

# Calling cleanup QM directory to workaround exit code once
# /var/qm disk is full.
podman exec -it qm /bin/bash -c 'podman  rmi -i -f --all; echo $?'
