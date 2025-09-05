#!/bin/bash

# 備份 VM 到 USB 腳本
# 用途：將 PVE VM 備份檔案寫入 USB 裝置
# 使用方式：./backup_to_usb.sh <VMID>

#################### 函式 ####################
# 錯誤退出函式
function abort() {
    echo "⚠️ $1"
    if mountpoint -q "$USB_MOUNT"; then
        echo "🔄 嘗試卸載 USB 裝置..."
        sync
        sudo umount "$USB_MOUNT"
    fi
    exit 1
}

# 建立備份資訊檔
function write_backup_info() {
    local info_file="$USB_BACKUP_DIR/backup_info.txt"
    {
        echo "VM ID: $VMID"
        echo "備份日期: $DATE"
        echo "原始檔案: $LATEST_BACKUP"
        echo "PVE 主機: $(hostname)"
    } > "$info_file"
    echo "📝 備份資訊已寫入 $info_file"
}

# 卸載 USB 裝置
function unmount_usb() {
    echo "🔄 sync..."
    sync
    echo "🔄 卸載 USB 裝置..."
    if sudo umount "$USB_MOUNT"; then
        echo "✅ USB 卸載成功"
    else
        abort "⚠️ USB 卸載失敗"
    fi
}

# 執行 vzdump 備份
function do_backup() {
    echo "開始執行 vzdump 備份..."
    vzdump "$VMID" --compress zst --mode snapshot || abort "備份失敗"
    
    BACKUPS=( $(ls -t vzdump-qemu-$VMID-* 2>/dev/null) )
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        abort "備份完成，但找不到備份檔"
    fi
    SELECTED_BACKUP="${BACKUPS[0]}"
    echo "使用新產生的備份檔: $SELECTED_BACKUP"
}

#################### 主流程 ####################


#### 檢查參數 ####

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


#### 備份 VM + 事前檢查 ####

cd "$BACKUP_DIR" || abort "無法切換備份目錄"
BACKUPS=( $(ls -t vzdump-qemu-$VMID-* 2>/dev/null) )

if [ ${#BACKUPS[@]} -eq 0 ]; then
    # 沒有備份，直接做備份
    do_backup
else
    echo "請選擇備份檔案或執行新的備份："
    for i in "${!BACKUPS[@]}"; do
        echo "$((i+1))) ${BACKUPS[$i]}"
    done
    echo "N) 現在備份新檔案"
    echo "0) 取消"

    while true; do
        read -p "輸入編號或 N / 0: " choice
        case "$choice" in
            ''|*[!0-9Nn]*)
                echo "請輸入有效選項"
                ;;
            [1-9]*)
                if [ "$choice" -ge 1 ] && [ "$choice" -le ${#BACKUPS[@]} ]; then
                    SELECTED_BACKUP="${BACKUPS[$((choice-1))]}"
                    echo "選擇使用備份檔: $SELECTED_BACKUP"
                    break
                else
                    echo "請輸入有效的數字編號"
                fi
                ;;
            [Nn])
                do_backup
                break
                ;;
            0)
                echo "取消操作"
                exit 0
                ;;
        esac
    done
fi



#### 移到 USB 上 ####

# 顯示可用裝置
echo "🔍 lsblk:"
lsblk
echo "=========================="

# 讀取使用者輸入的裝置名稱
while true; do
    read -p "請輸入 USB 裝置名稱 (例如 sdb): " USB_DEVICE

    if [ -z "$USB_DEVICE" ]; then
        echo "⚠️ 未提供裝置名稱"
        continue
    fi

    if [ ! -b "/dev/$USB_DEVICE" ]; then
        echo "⚠️ 裝置 /dev/$USB_DEVICE 不存在"
        continue
    fi

    echo "✅ 裝置 /dev/$USB_DEVICE 存在"
    break
done

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


# 選擇複製方法
echo "請選擇複製方式:"
echo "1) cp (預設)"
echo "2) rsync"
echo "3) dd"
echo "4) ddrescue"
read -p "選擇 (1-4): " COPY_METHOD

case $COPY_METHOD in
    2) COPY_TOOL="rsync" ;;
    3) COPY_TOOL="dd" ;;
    4) COPY_TOOL="ddrescue" ;;
    *) COPY_TOOL="cp" ;;
esac


# 複製最新的備份檔案
echo "📦 複製備份檔案到 USB..."
cd $BACKUP_DIR

LATEST_BACKUP=$(ls -t vzdump-qemu-$VMID-* | head -n1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "⚠️ 找不到 VM $VMID 的備份檔案"
    sudo umount $USB_MOUNT
    exit 1
fi


# 執行複製
case $COPY_TOOL in
    cp)
        echo "👉 使用 cp 複製 $LATEST_BACKUP 到 $USB_BACKUP_DIR"
        cp "$LATEST_BACKUP" "$USB_BACKUP_DIR/"
        ;;
    rsync)
        echo "👉 使用 rsync 複製 $LATEST_BACKUP 到 $USB_BACKUP_DIR"
        rsync -av --progress "$LATEST_BACKUP" "$USB_BACKUP_DIR/"
        ;;
    dd)
        echo "👉 使用 dd 複製檔案 (位元層，不建議用於單檔案備份)"
        dd if="$LATEST_BACKUP" of="$USB_BACKUP_DIR/$(basename $LATEST_BACKUP)" status=progress
        ;;
    ddrescue)
        echo "👉 使用 ddrescue 複製檔案（需要安裝 gddrescue）"
        ddrescue "$LATEST_BACKUP" "$USB_BACKUP_DIR/$(basename $LATEST_BACKUP)"
        ;;
    *)
        echo "❌ 不支援的複製工具"
        sudo umount "$USB_MOUNT"
        exit 1
        ;;
esac

# 檢查是否成功
if [ $? -eq 0 ]; then
    echo "✅ 檔案複製完成"

    # 建立備份資訊檔
    INFO_FILE="$USB_BACKUP_DIR/backup_info.txt"
    {
        echo "VM ID: $VMID"
        echo "備份日期: $DATE"
        echo "原始檔案: $LATEST_BACKUP"
        echo "PVE 主機: $(hostname)"
    } > "$INFO_FILE"

    echo "📝 備份資訊已寫入 $INFO_FILE"
else
    echo "⚠️ 檔案複製失敗"
    sudo umount "$USB_MOUNT"
    exit 1
fi


write_backup_info

echo "📋 已複製的檔案："
ls -lh "$USB_BACKUP_DIR"

unmount_usb

echo "✅ 備份完成！可以安全移除 USB 裝置"
