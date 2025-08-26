cat <<EOF > /etc/pve/qemu-server/110.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-110
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-110-disk-0,iothread=1,size=32G
scsi1: local-lvm:vm-110-disk-2
ide2: local-lvm:vm-110-cloudinit,media=cdrom
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:11:00,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/111.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-111
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-111-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:11:01,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/120.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-120
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-120-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:12:00,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/121.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-121
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-121-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:12:01,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/122.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-122
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-122-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:12:02,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/499.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-499
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-499-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:49:09,bridge=vmbr0,firewall=1
EOF

cat <<EOF > /etc/pve/qemu-server/1001.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-1001
machine: q35
meta: creation-qemu=8.1.5,ctime=1752483292
ostype: l26
scsi0: local-lvm:vm-1001-disk-0,iothread=1,size=32G
ide2: local-lvm:vm-1001-cloudinit,media=cdrom
scsihw: virtio-scsi-single
sockets: 1
vga: qxl
net0: virtio=DE:AD:BE:EF:10:01,bridge=vmbr0,firewall=1
EOF
