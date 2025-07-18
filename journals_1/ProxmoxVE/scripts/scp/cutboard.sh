free -h
df -h
lsblk
lspci | grep -i vga
nvidia-smi
rocm-smi
ifconfig
systemd-detect-virt
qm list
# qm status
vgs
lvs

qm create 130 --name "test0603-1" --memory 2048 \
 --cores 1 --cpu "x86-64-v2-AES" --ide2 "local-iso/ubuntu-22.04.5-live-server-amd64.iso,media=cdrom" \
 --net0 "virtio,bridge=vmbr1,firewall=1" --node-name "mbpc220908" --numa 0 \
 --ostype l26 --scsi0 "local-zfs:format=qcow2,iothread=on" --scsihw "virtio-scsi-single" \
 --sockets 1 --vga qxl --vmid 130
 
qm create 603 \  --name test0603-1 --memory 2048 \
  --cores 1 --sockets 1 --cpu x86-64-v2-AES \
  --machine q35 --net0 virtio,bridge=vmbr1,firewall=1 \
  --ostype l26 --scsihw virtio-scsi-single \
  --vga qxl --boot order=scsi0,net0 \
  --scsi0 local-lvm:vm-603-disk-0,format=qcow2,iothread=on \
  --agent enabled=1

  qm create 603 \
  --name test0603-1 \
  --memory 2048 \
  --cores 1 \
  --sockets 1 \
  --cpu x86-64-v2-AES \
  --machine q35 \
  --boot order=scsi0;net0\
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --vga qxl \
  --scsi0 local-lvm:vm-603-disk-0,format=qcow2,iothread=1 \
  --agent enabled=1


qm create 603 --name test0603-1 --memory 2048 --cores 1 --sockets 1 --cpu x86-64-v2-AES --machine q35 --net0 virtio,bridge=vmbr0,firewall=1 --ostype l26 --scsihw virtio-scsi-single --vga qxl --boot order=scsi0 --scsi0 local-lvm:vm-603-disk-0,format=qcow2,iothread=1 --agent enabled=1


cat <<EOF > /etc/pve/qemu-server/101.conf
boot: order=scsi0
cores: 2
memory: 2048
name: mbvm250604
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-101-disk-0
ide2: local-lvm:vm-101-cloudinit,media=cdrom
net0: virtio=DE:AD:BE:EF:10:10,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/110.conf
boot: order=scsi0
cores: 2
memory: 2048
name: mbvm250603
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-110-disk-0
scsi1: local-lvm:vm-110-disk-2
ide2: local-lvm:vm-110-cloudinit,media=cdrom
net0: virtio=DE:AD:BE:EF:11:00,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/111.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-111
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-111-disk-0
net0: virtio=DE:AD:BE:EF:11:01,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/120.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-120
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-120-disk-0
net0: virtio=DE:AD:BE:EF:12:00,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/121.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-121
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-121-disk-0
net0: virtio=DE:AD:BE:EF:12:01,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/122.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-122
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-122-disk-0
net0: virtio=DE:AD:BE:EF:12:02,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/499.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-499
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-499-disk-0
net0: virtio=DE:AD:BE:EF:49:09,bridge=vmbr0
EOF

cat <<EOF > /etc/pve/qemu-server/1001.conf
boot: order=scsi0
cores: 2
memory: 2048
name: vm-1001
scsihw: virtio-scsi-pci
scsi0: local-lvm:vm-1001-disk-0
ide2: local-lvm:vm-1001-cloudinit,media=cdrom
net0: virtio=DE:AD:BE:EF:10:01,bridge=vmbr0
EOF


agent: 1
boot: order=scsi0;net0
ciuser: boot603
cores: 4
cpu: x86-64-v2-AES
machine: q35
vga: qxl
memory: 2048
name: boot
net0: virtio=BC:04:21:5D:1B:E2,bridge=vmbr0,firewall=1
ostype: l26
scsi0: local-lvm:vm-603-disk-0,iothread=1,size=32G
scsihw: virtio-scsi-single
sockets: 1
