#!/bin/bash

# 備份 VM 到 USB 腳本
# 用途：將 PVE VM 備份檔案寫入 USB 裝置
# 使用方式：./backup_to_usb.sh <VMID>

# 檢查參數
if [ -z "$1" ]; then
    echo "⚠️ 請提供 VMID"
    echo "使用方式: $0 <VMID>"
    exit 1
fi

VMID=$1
USB_MOUNT="/mnt/usb"
BACKUP_DIR="/var/lib/vz/dump"
DATE=$(date +%Y_%m_%d)

# 確認在 PVE 主機上執行
if ! command -v qm &> /dev/null; then
    echo "⚠️ 此腳本必須在 PVE 主機上執行"
    exit 1
fi

# 檢查 VM 是否存在
if ! qm status $VMID &> /dev/null; then
    echo "⚠️ VM $VMID 不存在"
    exit 1
fi

# 執行備份
echo "🔄 開始備份 VM $VMID..."
vzdump $VMID --compress zst --mode snapshot

# 顯示可用裝置
echo "🔍 lsblk:"
lsblk
echo "=========================="

# 讀取使用者輸入的裝置名稱
read -p "請輸入 USB 裝置名稱 (例如 sdb): " USB_DEVICE
if [ -z "$USB_DEVICE" ]; then
    echo "⚠️ 未提供裝置名稱"
    exit 1
fi

# 確認裝置存在
if [ ! -b "/dev/$USB_DEVICE" ]; then
    echo "⚠️ 裝置 /dev/$USB_DEVICE 不存在"
    exit 1
fi

# 建立掛載點
echo "📂 建立掛載點..."
mkdir -p $USB_MOUNT

# 掛載 USB
echo "🔄 掛載 USB 裝置..."
if mount "/dev/$USB_DEVICE" $USB_MOUNT; then
    echo "✅ USB 掛載成功"
else
    echo "⚠️ USB 掛載失敗"
    exit 1
fi

# 在 USB 上建立備份目錄
USB_BACKUP_DIR="$USB_MOUNT/pve_backups/$VMID"
mkdir -p "$USB_BACKUP_DIR"

# 複製最新的備份檔案
echo "📦 複製備份檔案到 USB..."
cd $BACKUP_DIR
LATEST_BACKUP=$(ls -t vzdump-qemu-$VMID-* | head -n1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "⚠️ 找不到 VM $VMID 的備份檔案"
    sudo umount $USB_MOUNT
    exit 1
fi

if cp $LATEST_BACKUP "$USB_BACKUP_DIR/"; then
    echo "✅ 檔案複製完成"
    # 建立備份資訊檔
    echo "VM ID: $VMID" > "$USB_BACKUP_DIR/backup_info.txt"
    echo "備份日期: $DATE" >> "$USB_BACKUP_DIR/backup_info.txt"
    echo "原始檔案: $LATEST_BACKUP" >> "$USB_BACKUP_DIR/backup_info.txt"
    echo "PVE 主機: $(hostname)" >> "$USB_BACKUP_DIR/backup_info.txt"
else
    echo "⚠️ 檔案複製失敗"
    sudo umount $USB_MOUNT
    exit 1
fi

# 顯示複製的檔案
echo "📋 已複製的檔案："
ls -lh "$USB_BACKUP_DIR"

# 同步檔案系統
echo "🔄 同步檔案系統..."
sync

# 卸載 USB
echo "🔄 卸載 USB 裝置..."
if sudo umount $USB_MOUNT; then
    echo "✅ USB 卸載成功"
else
    echo "⚠️ USB 卸載失敗"
    exit 1
fi

echo "✅ 備份完成！可以安全移除 USB 裝置"