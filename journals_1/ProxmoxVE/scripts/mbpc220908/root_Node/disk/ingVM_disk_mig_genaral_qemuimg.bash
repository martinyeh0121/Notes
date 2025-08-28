#!/bin/bash

set -e

# 設定 WORKDIR 為腳本目錄
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 讀取參數
read -p "輸入來源 VM ID (src_vmid): " SRC_VMID
read -p "輸入來源磁碟名稱 (例如 vm-${SRC_VMID}-disk-2): " SRC_DISK_NAME
read -p "輸入來源 type (raw / qcow2 / vmdk / lvm): " SRC_TYPE

read -p "輸入目標 VM ID (dst_vmid): " DST_VMID
read -p "輸入目標磁碟名稱 (例如 vm-${DST_VMID}-disk-2): " DST_DISK_NAME
read -p "輸入目標 type (raw / qcow2 / vmdk / lvm): " DST_TYPE

read -p "選擇 LV 快照大小 (default: 4G): " SNAP_SIZE
read -p "選擇 cluster(bs) 大小 (default: 512M): " CLUSTER_SIZE


## ------------------------------------------------------------------

# 預設值
SNAP_SIZE=${SNAP_SIZE:-4G}
CLUSTER_SIZE=${CLUSTER_SIZE:-512M}
SRC_DISK_NAME=${SRC_DISK_NAME:-vm-${SRC_VMID}-disk-2}
DST_DISK_NAME=${DST_DISK_NAME:-vm-${DST_VMID}-disk-2}

set_dir() {
    local -n type="$1"
    local -n vmid="$2"
    local -n name="$3"
    local -n varname="$4"

    case "$type" in
        raw|qcow2|vmdk)
            name="${name}.${type}"
            varname="/var/lib/vz/images/${vmid}/${name}"
            ;;
        lvm)
            varname="/dev/pve/${name}"
            ;;
        *)
            echo "❌ 不支援的類型: $type"
            echo "請使用其中一個: raw, qcow2, vmdk, lvm"
            exit 1
            ;;
    esac
}

# 範例：傳入來源與目標格式、VMID
set_dir SRC_TYPE SRC_VMID SRC_DISK_NAME SRC_PATH
set_dir DST_TYPE DST_VMID DST_DISK_NAME DST_PATH

# Debug 輸出
echo "📂 SRC_PATH: $SRC_PATH"
echo "📂 DST_PATH: $DST_PATH"

SRC_DIR=$(dirname "$SRC_PATH")
DST_DIR=$(dirname "$DST_PATH")

# 
SNAP_NAME="snap_${SRC_DISK_NAME}"
# SRC_LV_PATH="/dev/pve/${SRC_DISK_NAME}"


## ------------------------------------------------------------------


# 1. 建立目標 VM 映像目錄
echo "建立目錄 $DST_DIR..."
mkdir -p "$DST_DIR"

# 2.1 建立 LVM snapshot
echo "建立 snapshot ${SNAP_NAME} 大小 ${SNAP_SIZE}..."
setsid lvcreate --size "${SNAP_SIZE}" --snapshot --name "${SNAP_NAME}" "${SRC_LV_PATH}"
# 用setsid 避免 File descriptor leaked

# 2.2 轉換成 qcow2 格式（使用 snapshot）
echo "轉換為 qcow2..."
qemu-img convert -p -f raw -O qcow2 -c "/dev/pve/${SNAP_NAME}" "${DST_DIR}/${DST_DISK_NAME}.qcow2"
# qemu-img convert -p -f raw -O vmdk -c "/dev/pve/${SNAP_NAME}" "${DST_DIR}/${DST_DISK_NAME}.vmdk"

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
qm set "${DST_VMID}" -${DISK_SLOT} "local:${DST_VMID}/${DST_DISK_NAME}.qcow2"

echo "✅ 完成磁碟轉換與掛載！"


# 4. 是否要進入 VM 掛載磁碟
read -p "是否進入 VM 掛載磁碟？(y/N): " SSHIN

if [[ "$SSHIN" =~ ^[Yy]$ ]]; then
  
  
  $WORKDIR/VM_disk_mount_ssh.bash  # ./VM_disk_mount_ssh
else
  echo "⚠️ 已略過 VM 掛載流程"
fi






# # 建立目錄
# mkdir -p /var/lib/vz/images/200

# # 建立 snapshot（避免 descriptor 洩漏使用 setsid）
# setsid lvcreate --size 2G --snapshot --name snap_vm-100-disk-2 /dev/pve/vm-100-disk-2

# # 轉換為 qcow2
# qemu-img convert -f raw -O qcow2 -c /dev/pve/snap_vm-100-disk-2 /var/lib/vz/images/200/disk-converted.qcow2

# # 刪除 snapshot
# setsid lvremove -f /dev/pve/snap_vm-100-disk-2

# # 顯示結果
# ls -lh /var/lib/vz/images/200