scp -r node:/root/script ./journals_1/ProxmoxVE/scripts/scp
# scp -r node:/root/script/root_Node/disk ./

rsync -av --exclude='jammy-server-cloudimg-amd64.img' node:/root/script/ ./journals_1/ProxmoxVE/scripts/scp/
