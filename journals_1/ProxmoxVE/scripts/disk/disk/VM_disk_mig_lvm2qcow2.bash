#!/bin/bash
set -e

# 設定 WORKDIR 為腳本目錄
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 讀取參數
read -p "輸入來源 VM ID (src_vmid): " SRC_VMID
read -p "輸入目標 VM ID (dst_vmid): " DST_VMID
read -p "輸入來源磁碟名稱 (例如 vm-${SRC_VMID}-disk-2): " SRC_DISK_NAME
read -p "輸入轉換後磁碟名稱 (例如 vm-${SRC_VMID}-disk-2, test , 使用 qcow2 格式): " NEW_DISK_NAME
read -p "選擇 LV 快照大小 (default: 2G): " SNAP_SIZE

# 預設快照大小
SNAP_SIZE=${SNAP_SIZE:-2G}

# 路徑
DST_DIR="/var/lib/vz/images/${DST_VMID}"
SRC_LV_PATH="/dev/pve/${SRC_DISK_NAME}"
SNAP_NAME="snap_${SRC_DISK_NAME}"

# 1. 建立目標 VM 映像目錄
echo "建立目錄 $DST_DIR..."
mkdir -p "$DST_DIR"

# 2.1 建立 LVM snapshot
echo "建立 snapshot ${SNAP_NAME} 大小 ${SNAP_SIZE}..."
setsid lvcreate --size "${SNAP_SIZE}" --snapshot --name "${SNAP_NAME}" "${SRC_LV_PATH}"
# 用setsid 避免 File descriptor leaked

# 2.2 轉換成 qcow2 格式（使用 snapshot）
echo "轉換為 qcow2..."
qemu-img convert -f raw -O qcow2 -c "/dev/pve/${SNAP_NAME}" "${DST_DIR}/${NEW_DISK_NAME}.qcow2"

# 2.3 移除 snapshot
echo "移除 snapshot..."
setsid lvremove -f "/dev/pve/${SNAP_NAME}"

# 2.4 驗證轉換結果
echo "檔案清單："
ls -lh "${DST_DIR}"

# 3. 加入到目標 VM
read -p "請輸入 VM 磁碟槽位 (預設 scsi3): " DISK_SLOT
DISK_SLOT=${DISK_SLOT:-scsi3}   # 沒輸入就用預設

echo "設定磁碟到 VM ${DST_VMID} 的 ${DISK_SLOT}..."
qm set "${DST_VMID}" -${DISK_SLOT} "local:${DST_VMID}/${NEW_DISK_NAME}"

echo "✅ 完成磁碟轉換與掛載！"


# 4. 是否要進入 VM 掛載磁碟
read -p "是否進入 VM 掛載磁碟？(y/N): " SSHIN

if [[ "$SSHIN" =~ ^[Yy]$ ]]; then
  
  
  $WORKDIR/VM_disk_mount_ssh.bash  # ./VM_disk_mount_ssh
else
  echo "⚠️ 已略過 VM 掛載流程"
fi

