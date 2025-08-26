#!/bin/bash
set -e

# 設定 WORKDIR 為腳本目錄
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 讀取參數
read -p "輸入來源 VM ID (src_vmid): " SRC_VMID
read -p "輸入目標 VM ID (dst_vmid): " DST_VMID
read -p "輸入來源磁碟名稱 (例如 vm-${SRC_VMID}-disk-0): " SRC_DISK_NAME
read -p "輸入覆蓋磁碟名稱 (例如 vm-${DST_VMID}-disk-0): " NEW_DISK_NAME
read -p "選擇 LV 快照大小 (default: 4G): " SNAP_SIZE
read -p "選擇 dd bs 大小 (default: 512M): " BS_SIZE

# 預設值
SNAP_SIZE=${SNAP_SIZE:-4G}
BS_SIZE=${BS_SIZE:-512M}
SRC_DISK_NAME=${SRC_DISK_NAME:-vm-${SRC_VMID}-disk-0}
NEW_DISK_NAME=${NEW_DISK_NAME:-vm-${DST_VMID}-disk-0}

# 路徑
DST_DIR="/var/lib/vz/images/${DST_VMID}"
SRC_LV_PATH="/dev/pve/${SRC_DISK_NAME}"
SNAP_NAME="snap_${SRC_DISK_NAME}"

# # 1. 建立目標 VM 映像目錄
# echo "建立目錄 $DST_DIR..."
# mkdir -p "$DST_DIR"

# 1 建立 LVM snapshot
echo "建立 snapshot ${SNAP_NAME} 大小 ${SNAP_SIZE}..."
setsid lvcreate --size "${SNAP_SIZE}" --snapshot --name "${SNAP_NAME}" "${SRC_LV_PATH}"
# 用setsid 避免 File descriptor leaked

# 2 覆寫目標系統碟（使用 snapshot）
echo "覆寫中 ..."
# qemu-img convert -f raw -O qcow2 -c "/dev/pve/${SNAP_NAME}" "${DST_DIR}/${NEW_DISK_NAME}.qcow2"
dd if="/dev/pve/${SNAP_NAME}" of="/dev/pve/${NEW_DISK_NAME}" bs="${BS_SIZE}" status=progress conv=fsync

# 3 移除 snapshot
echo "移除 snapshot..."
setsid lvremove -f "/dev/pve/${SNAP_NAME}"

# 4 驗證轉換結果
echo "檔案清單："
ls -l "/dev/pve" | grep "${DST_VMID}"

echo "✅ 完成系統碟覆寫！"

