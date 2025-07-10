# 修改 PVE source 為 no-subscription 
sed -i 's|https://enterprise.proxmox.com|http://download.proxmox.com|g; s|enterprise|no-subscription|g' /etc/apt/sources.list.d/pve-enterprise.list
# 修改 Ceph source 為 no-subscription 
sed -i 's|https://enterprise.proxmox.com|http://download.proxmox.com|g; s|enterprise|no-subscription|g' /etc/apt/sources.list.d/ceph.list

# 更新 APT 套件清單
apt update