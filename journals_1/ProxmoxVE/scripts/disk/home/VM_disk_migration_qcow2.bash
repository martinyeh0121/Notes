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


# if [[ "$SSHIN" =~ ^[Yy]$ ]]; then
#   read -p "請輸入 VM 的 SSH 位址（例如 user@mbvmtest0）: " SSH_TARGET
#   MOUNT_POINT=${MOUNT_POINT:-/mnt/selected_disk}

#   ssh -t "$SSH_TARGET" bash -c "'
#     echo \"目前系統磁碟與分割區列表：\"
#     lsblk

#     read -p \"請輸入要掛載的磁碟區（例如 /dev/sdb1）: \" PARTITION
#     read -p \"請輸入要掛載的目錄 \(預設 /mnt/selected_disk\): \" MOUNT_POINT

#     if [ ! -b \"\$PARTITION\" ]; then
#       echo \"錯誤：磁碟區 \$PARTITION 不存在！\"
#       exit 1
#     fi

#     echo \"建立掛載點 ${MOUNT_POINT}...\"
#     sudo mkdir -p ${MOUNT_POINT}

#     echo \"掛載磁碟區 \$PARTITION 到 ${MOUNT_POINT}...\"
#     sudo mount \$PARTITION ${MOUNT_POINT}

#     echo \"掛載結果：\"
#     df -h ${MOUNT_POINT}
#     ls ${MOUNT_POINT}

#     echo \"建立測試檔案 omg.txt...\"
#     echo \"這是測試內容\" | sudo tee ${MOUNT_POINT}/omg.txt
#     echo \"✅ 完成掛載並建立檔案。\"
#   '"
# else
#   echo "⚠️ 已略過 VM 掛載流程"
# fi

# ## 前置檢查指令
# lsblk                        # 查看系統目前的磁碟與分割區（確認 sdb1 存在）
# sudo fdisk -l /dev/sd*       # 檢查 /dev/sdb 分割表與格式資訊（確保 sdb1 有格式化）

# ## mount
# sudo mkdir -p /mnt/sdb       # 建立 mount point
# sudo mount /dev/sdb1 /mnt/sdb  # 將 /dev/sdb1 分割區掛載到 /mnt/sdb 資料夾

# # df -h /mnt/sdb               # 確認是否成功掛載
# # ls /mnt/sdb                  # 檢查掛載後資料夾中是否有內容（驗證是否正常讀寫）

# ## check

# sudo nano /mnt/sdb/omg.txt
