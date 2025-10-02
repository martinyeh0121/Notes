#!/bin/bash

### 參數化路徑 ###
ETC_HOSTS="/etc/hosts"
PVE_NODES_DIR="/etc/pve/nodes"
CEPH_CONF="/etc/pve/ceph.conf"
COROSYNC_CONF="/etc/pve/corosync.conf"
SYSTEMD_MON_DIR="/etc/systemd/system/ceph-mon.target.wants"
AUTHORIZED_KEYS="/etc/pve/priv/authorized_keys"

### 自動抓取舊主機名稱 ###
OLD=$(hostname)
echo "🔍 偵測到目前主機名稱為：$OLD"

### 讀取新主機名稱 ###
echo "請輸入新主機名稱 (new hostname):"
read NEW

### 執行摘要 ###
echo ""
echo "📝 執行摘要："
echo "--------------------------------------"
echo " 舊主機名稱: $OLD"
echo " 新主機名稱: $NEW"
echo " 將執行以下動作："
echo "  - 修改 $ETC_HOSTS"
echo "  - 設定新 hostname"
echo "  - 複製 $PVE_NODES_DIR/$OLD 到 $PVE_NODES_DIR/$NEW"
echo "  - 替換 $CEPH_CONF 和 $COROSYNC_CONF 中的主機名稱"
echo "  - 增加 corosync config_version"
echo "  - 重命名 Ceph crush bucket"
echo "  - 重命名 ceph-mon systemd 服務檔案"
echo "--------------------------------------"
echo ""

read -p "是否確認執行以上動作？(y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "❌ 操作已取消。"
    exit 1
fi


### corosync.conf 相關 ###
### 抓目前 corosync config_version ###
CURRENT_VER=$(grep -E "^[[:space:]]*config_version:" "$COROSYNC_CONF" | awk '{print $2}')
if [[ -z "$CURRENT_VER" ]]; then
    echo "❌ 找不到 config_version，請手動確認 corosync.conf 格式"
    exit 1
fi
NEW_VER=$((CURRENT_VER + 1))


### 更新 authorized_keys ###  
OLD_KEY="root@$OLD"
NEW_KEY="root@$NEW"
# 檢查是否已存在 NEW_KEY
if grep -Eq "$NEW_KEY([[:space:]]|\$)" "$AUTHORIZED_KEYS"; then
    echo "❗ $NEW_KEY 已存在於 $AUTHORIZED_KEYS，請手動處理。"
    exit 1
fi


# 檢查 OLD_KEY 是否存在
if grep -Eq "$OLD_KEY([[:space:]]|\$)" "$AUTHORIZED_KEYS"; then
    echo "🔧 正在將 $OLD_KEY ➜ $NEW_KEY..."
    sed -Ei "s/(root@$OLD)([[:space:]]|\$)/root@$NEW\2/g" "$AUTHORIZED_KEYS"
    echo "✅ 已完成替換：$OLD_KEY ➜ $NEW_KEY"
else
    echo "⚠️ 未找到 $OLD_KEY，無法替換，請手動確認。"
    exit 1
fi


### 修改 /etc/hosts ###
echo "🔧 修改 $ETC_HOSTS..."
sed -i "s/$OLD/$NEW/g" "$ETC_HOSTS"


### 設定 hostname ###
echo "🔧 設定新 hostname..."
hostnamectl set-hostname "$NEW"


### 複製 node 設定 ###
echo "🔧 複製 PVE node 設定..."
# mkdir -p "$PVE_NODES_DIR/$NEW"
mkdir -p "${HOME}/backup/"
cp -r "$PVE_NODES_DIR/$OLD" "${HOME}/backup"
cp -r "$PVE_NODES_DIR/$OLD/" "$PVE_NODES_DIR/$NEW/"
mv "$PVE_NODES_DIR/$OLD/qemu-server"* "$PVE_NODES_DIR/$NEW/qemu-server"

echo "✅ 已完成複製 PVE node 設定..."
echo "✅ 備份路徑：${HOME}/backup/$OLD"

### 更新 ceph.conf 和 corosync.conf ###
echo "🔧 更新主機名稱於設定檔..."
sed -i "s/$OLD/$NEW/g" "$CEPH_CONF"
sed -i "s/$OLD/$NEW/g" "$COROSYNC_CONF"


# 更新 config_version 到 corosync.conf
sed -i "s/^\([[:space:]]*config_version:\)[[:space:]]*$CURRENT_VER/\1 $NEW_VER/" "$COROSYNC_CONF"
echo "✅ config_version 已從 $CURRENT_VER ➜ $NEW_VER"


### Ceph crush bucket 改名 ###
echo "🔧 修改 Ceph crush map..."
ceph osd crush rename-bucket "$OLD" "$NEW"



### 重啟相關服務 ###
read -p "是否確認重啟相關服務？(y/n): " confirm
if [[ "$confirm" == "y" ]]; then
    systemctl restart corosync.service pve-cluster.service ceph.target pvestatd.service
    pvecm updatecerts
    systemctl restart pveproxy.service pvedaemon.service
fi

echo "✅ 所有修改已完成。請手動重建 cephmgr 和 cephmon 服務"