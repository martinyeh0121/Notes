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