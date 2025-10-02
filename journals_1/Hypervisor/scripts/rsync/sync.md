``` sh
scp -r node:/root/script ./journals_1/ProxmoxVE/scripts/scp
# scp -r node:/root/script/root_Node/disk ./


# --delete
rsync -avh ~/home/rsync/ /mnt/c/Users/marti/Desktop/intern/code/notes/journals_1/Hypervisor/scripts/rsync
# 正向 (cpy to windows)
rsync -avh --exclude='*.img' node:/root/script/ /mnt/c/Users/marti/Desktop/intern/code/notes/journals_1/ProxmoxVE/scripts/rsync/mbpc220908
rsync -avh ~/home/rsync/bash/ /mnt/c/Users/marti/Desktop/intern/code/notes/journals_1/ProxmoxVE/scripts/rsync/wsl_bash/

# 反向
# all to wsl
rsync -avh ./journals_1/ProxmoxVE/scripts/rsync/ ~/home/rsync/
# cpy to WSL / mbpc220908
rsync -avh --exclude='*.img' node:/root/script/ /mnt/c/Users/marti/Desktop/intern/code/notes/journals_1/ProxmoxVE/scripts/rsync/mbpc220908
rsync -avh /mnt/c/Users/marti/Desktop/intern/code/notes/journals_1/ProxmoxVE/scripts/rsync/wsl_bash/ ~/home/rsync/bash/



timedatectl set-timezone Asia/Taipei

sudo sh -c "echo \"UUID=$(blkid -s UUID -o value /dev/sdb)  /mnt/data  ext4  defaults  0  2\" >> /etc/fstab"
```


