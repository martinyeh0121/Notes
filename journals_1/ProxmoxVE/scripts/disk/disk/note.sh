
## disk to qcow2

# 流程
# 1. 建立目標 VM 映像目錄（如果還沒建立）
mkdir -p /var/lib/vz/images/121/

# 2. 轉換並輸出到目標資料夾

lvcreate --size 2G --snapshot --name snap_vm110_disk0 /dev/pve/vm-110-disk-0
qemu-img convert -f raw -O qcow2 -c /dev/pve/vm-110-disk-0 /var/lib/vz/images/121/vm-110-disk-0.qcow2
lvremove /dev/pve/snap_vm110_disk2mv

# 3. 驗證檔案是否存在
ls -lh /var/lib/vz/images/121/

# 4. Cli 新增硬碟到目標vm
qm set 121 -scsi3 local:121/vm-110-disk-2.qcow2
