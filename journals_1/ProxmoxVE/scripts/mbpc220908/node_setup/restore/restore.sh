tee /etc/pve/storage.cfg > /dev/null <<EOF
dir: local
    path /var/lib/vz
    content backup,iso,rootdir,vztmpl,images
    maxfiles 1
    shared 0

lvmthin: local-lvm
    thinpool data
    vgname pve
    content rootdir,images


# qemu-server (confs)


# 