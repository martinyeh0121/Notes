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