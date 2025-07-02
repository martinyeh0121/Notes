mkdir -p /var/lib/vz/images/121/

lvcreate --size 2G --snapshot --name snap_vm110_disk0 /dev/pve/vm-110-disk-0
qemu-img convert -f raw -O qcow2 -c /dev/pve/vm-110-disk-0 /var/lib/vz/images/121/vm-110-disk-0.qcow2
lvremove /dev/pve/snap_vm110_disk2mv


qm set 121 -scsi3 local:121/vm-110-disk-2.qcow2

