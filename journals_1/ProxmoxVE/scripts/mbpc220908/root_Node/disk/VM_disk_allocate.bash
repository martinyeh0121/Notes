## 流程
# # 1. 建立目標 VM 映像目錄（如果還沒建立）
# mkdir -p /var/lib/vz/images/121/

# # 2. 轉換並輸出到目標資料夾

# lvcreate --size 2G --snapshot --name snap_vm110_disk0 /dev/pve/vm-110-disk-0
# qemu-img convert -f raw -O qcow2 -c /dev/pve/vm-110-disk-0 /var/lib/vz/images/121/vm-110-disk-0.qcow2
# lvremove /dev/pve/snap_vm110_disk2mv

# # 3. 驗證檔案是否存在
# ls -lh /var/lib/vz/images/121/

# # 4. Cli 新增硬碟到目標vm
# qm set 121 -scsi3 local:121/vm-110-disk-2.qcow2


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





pvesm alloc local 702 test.qcow2 2G  # test.qcow2