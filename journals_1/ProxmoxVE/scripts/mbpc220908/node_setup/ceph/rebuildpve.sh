
# cp -r ./ ~/backup/0815/

# ===== 重要說明 =====
# 此腳本用於重建 PVE 和 Ceph 環境
# 
# 執行前請注意：
# 1. PVE 系統設定不會被移除
# 2. Ceph kernel 模組會被移除，之後需重新安裝
# 3. APT Repository 會更新至 Ceph Reef 版本
# 4. 建議執行前先備份重要資料
#
# 使用方式：
# 1. 建議先備份：cp -r ./ ~/backup/$(date +%Y%m%d)/
# 2. 執行腳本：bash rebuildpve.sh
#

set -e

# 顯示警告訊息
echo "============================================================"
echo "警告：此操作將重建 PVE 和 Ceph 環境，請確認以下事項："
echo "1. PVE 系統設定將保留"
echo "2. Ceph kernel 模組將被移除"
echo "3. APT Repository 將調整至 Ceph Reef 版本"
echo "4. 建議已完成資料備份 (免責聲明：不保證資料完全可復原，請自行承擔風險，測試為移除squid (19.2)版本，且ceph設定已事先移除)"
echo "============================================================"

# 要求使用者確認
read -p "您確定要繼續嗎？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "操作已取消"
    exit 1
fi

echo "===== Step 1: 停止所有 Ceph 服務 ====="
systemctl stop ceph.target || true
systemctl stop ceph-osd.target || true

echo "===== Step 2: 清理 PVE + 殘留 Ceph v19 套件 ====="
touch /please-remove-proxmox-ve
# apt purge ceph ceph-common ceph-mds ceph-mon ceph-osd ceph-mgr cephadm -y # 清理 PVE + 殘留 Ceph v18 套件
apt purge -y ceph\* ceph-fuse libcephfs2 librados2 libradosstriper1 librgw2 python3-rados python3-rgw python3-ceph\* 
apt autoremove -y
apt clean

# 清理殘留 (ceph 設定)
rm -rf /etc/ceph
rm -rf /var/lib/ceph

echo "===== Step 3: 確認系統乾淨 ====="
dpkg -l | grep ceph || echo "Ceph 已完全移除"
dpkg -l | grep librbd || echo "librbd 套件已移除"

# 復原 repo
echo "===== Step 4: 設定 PVE + Ceph v18 repo ====="
# PVE non-subscription repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-enterprise.list
# Ceph Pacific repo
echo "deb http://download.proxmox.com/debian/ceph-reef bookworm main" > /etc/apt/sources.list.d/ceph.list

# 更新 APT 套件清單
apt update

echo "===== Step 5: 重安裝 PVE  ====="

# 安裝 PVE 套件 (標準安裝)
# pve-ha-manager spiceterm
apt install proxmox-ve postfix open-iscsi spiceterm -y 
# apt install proxmox-ve -y
# 安裝 Ceph 套件
# apt install ceph ceph-common ceph-mds ceph-mon ceph-osd ceph-mgr cephadm -y