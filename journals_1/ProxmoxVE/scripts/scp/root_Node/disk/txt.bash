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

