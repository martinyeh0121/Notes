
# setsid lvcreate -s -n vm-121-snap -L4G /dev/pve/vm-121-disk-0

# dd if=/dev/pve/vm-121-snap of=/dev/pve/vm-102-disk-0 bs=512M status=progress conv=fsync

# setsid lvremove -y /dev/pve/vm-121-snap


# setsid lvcreate -s -n vm-120-snap -L4G /dev/pve/vm-120-disk-0

# dd if=/dev/pve/vm-120-snap of=/dev/pve/vm-111-disk-0 bs=512M status=progress conv=fsync

# setsid lvremove -y /dev/pve/vm-120-snap

setsid lvcreate -s -n vm-603-snap -L4G /dev/pve/vm-603-disk-0

dd if=/dev/pve/vm-603-snap of=/dev/ddtest-1 bs=512M status=progress conv=fsync

setsid lvremove -y /dev/pve/vm-603-snap
