#!/bin/bash

# 簡化版：從 USB 還原 PVE VM 備份
# 使用：./restore_from_usb.sh <VMID> <USB_DEVICE> （例如 sdb1）

USB_MOUNT="/mnt/usb"
RESTORE_DIR="/var/lib/vz/dump"
USB_BACKUP_DIR="$USB_MOUNT"

if [ -z "$1" ]; then
    read -p "請輸入 VMID: " VMID
    if [ -z "$VMID" ]; then
        echo "❌ 沒有輸入 VMID，退出。"
        exit 1
    fi
else
    VMID=$1
fi

lsblk
if [ -z "$2" ]; then
    read -p "請輸入 USB_DEVICE: " USB_DEVICE
    if [ -z "$USB_DEVICE" ]; then
        echo "❌ 沒有輸入 USB_DEVICE，退出。"
        exit 1
    fi
else
    USB_DEVICE=$2
fi

# --- 1. 驗證階段 ---

# 檢查參數
if [ -z "$VMID" ] || [ -z "$USB_DEVICE" ]; then
    echo "用法: $0 <VMID> <USB_DEVICE>"
    exit 1
fi

# 檢查是否在 PVE 主機上執行
command -v qm &> /dev/null || { echo "請在 PVE 主機上執行"; exit 1; }

# 檢查裝置存在
[ -b "/dev/$USB_DEVICE" ] || { echo "裝置 /dev/$USB_DEVICE 不存在"; exit 1; }

# 檢查備份目錄是否存在（稍後掛載後才檢查）

# --- 2. 執行階段 ---

# 掛載 USB
mkdir -p $USB_MOUNT
mount "/dev/$USB_DEVICE" $USB_MOUNT || { echo "USB 掛載失敗"; exit 1; }

# 檢查備份資料夾
if [ ! -d "$USB_BACKUP_DIR" ]; then
    echo "找不到備份目錄：$USB_BACKUP_DIR"
    umount $USB_MOUNT
    exit 1
fi

# 找到最新的備份檔
BACKUP_FILE=$(ls -t "$USB_BACKUP_DIR"/*.vma.zst 2>/dev/null | head -n1)
if [ -z "$BACKUP_FILE" ]; then
    echo "找不到備份檔案"
    umount $USB_MOUNT
    exit 1
fi

# 複製到 PVE 備份目錄
rsync -avP "$BACKUP_FILE" "$RESTORE_DIR/" || { echo "複製失敗"; umount $USB_MOUNT; exit 1; }

# 卸載
umount $USB_MOUNT || { echo "USB 卸載失敗"; exit 1; }

# --- 3. 還原階段 ---

RESTORE_FILE=$(basename "$BACKUP_FILE")

echo "✅ 備份檔已複製至 $RESTORE_DIR"
echo "👉 還原指令如下："
echo ""
echo "    qmrestore $RESTORE_DIR/$RESTORE_FILE $VMID"
echo ""
