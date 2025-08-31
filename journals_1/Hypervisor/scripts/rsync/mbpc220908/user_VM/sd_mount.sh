#!/bin/bash

set -e

# 檢查參數
if [ $# -ne 2 ]; then
  echo "用法: $0 <磁碟裝置> <掛載點>"
  echo "例如: $0 /dev/sdb /mnt/datab"
  exit 1
fi

# /dev/sdb /mnt/data1
# /dev/sdc /mnt/data2
# 變數
DISK=$1              # e.g. /dev/sdb
# PART_NUM=$2          # e.g. 1
PARTITION="${DISK}1"     # e.g. /dev/sdb1
MOUNT_POINT="$2"      # e.g. /mnt/data1

echo "⚠️  即將清除 ${DISK} 所有資料，5秒內按 Ctrl+C 可中止。"
sleep 5


# 嘗試卸載分割區
echo "👉 卸載分割區（如已掛載）..."
sudo umount "$PARTITION" 2>/dev/null || true

# 清除分割表
echo "👉 清除舊分割表..."
sudo wipefs -a "$DISK"

# 建立新分割（單一主分割區）
echo "👉 建立分割區..."
sudo parted -s "$DISK" mklabel msdos
sudo parted -s "$DISK" mkpart primary ext4 0% 100%

# 等待系統辨識新分割
sleep 2

# 格式化為 ext4
echo "👉 格式化為 ext4..."
sudo mkfs.ext4 "$PARTITION"

# 建立掛載點
echo "👉 建立掛載目錄 $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"

# 掛載分割區
echo "👉 掛載 $PARTITION 到 $MOUNT_POINT..."
sudo mount "$PARTITION" "$MOUNT_POINT"

# 取得 UUID
UUID=$(sudo blkid -s UUID -o value "$PARTITION")

# 備份並修改 /etc/fstab
echo "👉 設定 /etc/fstab 自動掛載..."
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i "\|$MOUNT_POINT|d" /etc/fstab  # 移除舊的掛載記錄（相同掛載點）
echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults  0  2" | sudo tee -a /etc/fstab

# 驗證掛載
echo "✅ 驗證掛載是否成功..."
mountpoint "$MOUNT_POINT" && echo "🎉 掛載成功：" && df -h "$MOUNT_POINT"
