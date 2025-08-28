scp -r node:/root/script ./journals_1/ProxmoxVE/scripts/scp
# scp -r node:/root/script/root_Node/disk ./

rsync -avh --exclude='jammy-server-cloudimg-amd64.img' node:/root/script/ ./journals_1/ProxmoxVE/scripts/rsync/mbpc220908
rsync -avh ~/home/bash/ ./journals_1/ProxmoxVE/scripts/rsync/wsl_bash
