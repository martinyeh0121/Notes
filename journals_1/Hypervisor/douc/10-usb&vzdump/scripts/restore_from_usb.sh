#!/bin/bash

# 從 USB 還原 VM 備份腳本
# 用途：從 USB 裝置還原 PVE VM 備份
# 使用方式：./restore_from_usb.sh <VMID>

# 檢查參數
if [ -z "$1" ]; then
    echo "⚠️ 請提供 VMID"
    echo "使用方式: $0 <VMID>"
    exit 1
fi

VMID=$1
USB_MOUNT="/mnt/usb"
RESTORE_DIR="/var/lib/vz/dump"

# 確認在 PVE 主機上執行
if ! command -v qm &> /dev/null; then
    echo "⚠️ 此腳本必須在 PVE 主機上執行"
    exit 1
fi

# 顯示可用裝置
echo "🔍 可用的塊裝置："
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

# 檢查備份檔案
USB_BACKUP_DIR="$USB_MOUNT/pve_backups/$VMID"
if [ ! -d "$USB_BACKUP_DIR" ]; then
    echo "⚠️ 找不到 VM $VMID 的備份目錄"
    sudo umount $USB_MOUNT
    exit 1
fi

# 顯示備份資訊
if [ -f "$USB_BACKUP_DIR/backup_info.txt" ]; then
    echo "📋 備份資訊："
    cat "$USB_BACKUP_DIR/backup_info.txt"
    echo "=========================="
fi

# 列出可用的備份檔案
echo "📋 可用的備份檔案："
ls -lh "$USB_BACKUP_DIR"/*.vma.zst
echo "=========================="

# 複製備份檔案到 PVE
echo "📦 複製備份檔案到 PVE..."
BACKUP_FILE=$(ls -t "$USB_BACKUP_DIR"/*.vma.zst | head -n1)
if [ -z "$BACKUP_FILE" ]; then
    echo "⚠️ 找不到備份檔案"
    sudo umount $USB_MOUNT
    exit 1
fi

if cp "$BACKUP_FILE" $RESTORE_DIR/; then
    echo "✅ 檔案複製完成"
else
    echo "⚠️ 檔案複製失敗"
    sudo umount $USB_MOUNT
    exit 1
fi

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

# 顯示還原指令
RESTORE_FILE=$(basename "$BACKUP_FILE")
echo "✅ 檔案傳輸完成！"
echo "👉 要還原 VM，請執行以下指令："
echo "qmrestore /var/lib/vz/dump/$RESTORE_FILE $VMID"