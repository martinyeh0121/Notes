wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# #cloud-config  (user-data.yaml)
# hostname: ubuntu-server
# timezone: Asia/Taipei

# users:
#   - name: ubuntu
#     groups: sudo
#     shell: /bin/bash
#     sudo: ALL=(ALL) NOPASSWD:ALL
#     ssh_authorized_keys:
#       - ssh-rsa AAAAB3NzaC1...YOUR_PUBLIC_KEY...

# package_update: true
# package_upgrade: true

# packages:
#   - tasksel
#   - net-tools
#   - curl
#   - vim
#   - git
#   - htop
#   - python3-pip
#   - openssh-server
#   - fail2ban
#   - ufw
#   - unzip

# write_files:
#   - path: /etc/needrestart/needrestart.conf
#     content: |
#       \$nrconf{restart} = 'a';

# runcmd:
#   - export DEBIAN_FRONTEND=noninteractive
#   - DEBIAN_FRONTEND=noninteractive tasksel install server
#   - systemctl enable ssh
#   - ufw allow OpenSSH
#   - ufw --force enable
#   - echo "✅ Server 初始化完成於 $(date)" >> /var/log/cloud-init-status.log


apt install cloud-image-utils

cloud-localds cidata.iso user-data.yaml

# # QEMU test 
# qemu-system-x86_64 \
#   -m 2048 \
#   -smp 2 \
#   -hda jammy-server-cloudimg-amd64.img \
#   -cdrom cidata.iso \
#   -net nic -net user,hostfwd=tcp::2222-:22 \
#   -nographic


qm create 9000 --name ubuntu-cloud --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --ostype l26
qm set 9000 --agent enabled=1,freeze-fs-on-backup=0
qm set 9000 --sshkey ~/.ssh/id_rsa_boot.pub # <your public ssk key path>





#!/bin/bash

cd /tmp

wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img

# 設定 CPU type 為 host, 共 8(2x4) vcpu, 8GB memory, 網路使用 vmbr1(tag 1310, 此為我自己設定的 trunk bridge)
qm create 9999 --cpu cputype=host --sockets 2 --cores 4 --memory 8192 --net0 virtio,bridge=vmbr1,tag=1310

# 將 cloud image 匯入到指定的 storage 作為 template VM 的第一個 disk
qm importdisk 9999 jammy-server-cloudimg-amd64.img local-lvm -d

# 設定 VM 細節
# 設定 storage type
# 設定 cloud-init 的功能以 cd-rom 的形式掛載
# serial 一定要加，否則 cloud image 會無法正常開機
qm set 9999 --virtio0 local-lvm:vm-9999-disk-0 --ide2 local-lvm:cloudinit --boot c --bootdisk virtio0 --serial0 socket

# 設定 SSH key (cloud image 預設是無法使用密碼登入，必須設定 SSH key)
qm set 9999 --sshkey ~/.ssh/id_rsa_boot.pub

# 轉換成 template VM
qm template 9999



#!/bin/bash

# 複製 VM
qm clone 9999 1001 --name ubuntu1604-1

# 將 storage size 擴大到 64GB
qm resize 1001 virtio0 32G; 

# 網路設定 (以下是對應到上面的 tag 1310，請自行修改以對應自己的環境)
# qm set 1001 --ipconfig0 ip=10.103.10.51/24,gw=10.103.10.1 --nameserver '8.8.8.8 1.1.1.1'
qm set 1001 --ipconfig0 ip=dhcp

qm start 1001