mkdir /mnt/iso
sudo mount -o loop ubuntu-22.04-live-server-amd64.iso /mnt/iso

``` yml
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-auto
    username: user
    password: "$6$rounds=4096$KfnDk8A8...$..."  # 使用 openssl passwd -6 產生加密密碼
  keyboard:
    layout: us
  locale: en_US.UTF-8
  storage:
    layout:
      name: direct
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - vim
    - curl
  late-commands:
    - curtin in-target --target=/target -- systemctl enable ssh
```


``` cfg
menuentry "autoinstall" {
	set gfxpayload=keep
	linux   /casper/vmlinuz autoinstall ds=nocloud\;s=/cdrom/autoinstall/ quiet ---
	initrd	/casper/initrd
}
menuentry "Try or Install Ubuntu Server" {
	set gfxpayload=keep
	linux	/casper/vmlinuz  ---
	initrd	/casper/initrd
}
```

``` sh
mkdir /mnt/iso
mkdir: cannot create directory ‘/mnt/iso’: Permission denied

sudo mkdir /mnt/iso
[sudo] password for martin:

ls /mnt
c  wsl  wslg

# 本機 /mnt/c/Users/marti/Downloads/ubuntu-22.04.5-live-server-amd64.iso
cd /mnt/c/Users/marti/Downloads/

sudo mount -o loop ubuntu-22.04.5-live-server-amd64.iso /mnt/iso
mount: /mnt/iso: WARNING: source write-protected, mounted read-only.

mkdir ~/custom-ubuntu-iso

cd ~

rsync -a /mnt/iso/ ~/custom-ubuntu-iso/

sudo umount /mnt/iso

mkdir -p ~/custom-ubuntu-iso/autoinstall
mkdir: cannot create directory ‘/home/martin/custom-ubuntu-iso/autoinstall’: Permission denied

sudo mkdir -p ~/custom-ubuntu-iso/autoinstall

sudo chown -r 1000:1000 ~/custom-ubuntu-iso
chown: invalid option -- 'r'
Try 'chown --help' for more information.

sudo chown -R 1000:1000 ~/custom-ubuntu-iso

ls custom-ubuntu-iso
EFI  autoinstall  boot  boot.catalog  casper  dists  install  md5sum.txt  pool  ubuntu

cd custom-ubuntu-iso/autoinstall/

ls

nano user-data

uname -r
5.15.167.4-microsoft-standard-WSL2

xorriso -as mkisofs \
  -r -V "CustomUbuntu22045" \
  -o ../custom_ubuntu_22.04.5.iso \
  -J -l \
  -c boot.catalog \
  -b boot/grub/i386-pc/eltorito.img \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
     -no-emul-boot \
  .
```