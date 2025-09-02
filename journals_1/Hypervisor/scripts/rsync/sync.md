``` sh
scp -r node:/root/script ./journals_1/ProxmoxVE/scripts/scp
# scp -r node:/root/script/root_Node/disk ./


# --delete

# 正向 (cpy to windows)
rsync -avh --exclude='jammy-server-cloudimg-amd64.img' node:/root/script/ ./journals_1/ProxmoxVE/scripts/rsync/mbpc220908
rsync -avh ~/home/rsync/wsl_bash/ ./journals_1/ProxmoxVE/scripts/rsync/wsl_bash/

# 反向 (cpy to WSL / mbpc220908)
# all to wsl
rsync -avh ./journals_1/ProxmoxVE/scripts/rsync/ ~/home/rsync/
# 
rsync -avh --exclude='jammy-server-cloudimg-amd64.img' node:/root/script/ ./journals_1/ProxmoxVE/scripts/rsync/mbpc220908
rsync -avh ./journals_1/Hypervisor/scripts/rsync/wsl_bash/ ~/home/rsync/wsl_bash/
```