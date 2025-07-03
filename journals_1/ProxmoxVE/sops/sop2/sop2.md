# 實體資料搬移 / 備份


Ref:

[PVE douc.](https://pve.proxmox.com/pve-docs/chapter-vzdump.html) (https://<urPVEserver>/pve-docs/chapter-vzdump.html) 

[LVM — pv, vg, lv!](https://sean22492249.medium.com/lvm-pv-vg-lv-1777a84a3ce8)

gpt

script:

[scripts](/journals_1/ProxmoxVE/scripts/disk/home/)


## Ver01: 直接 copy (qemu-img: 根據虛擬硬碟實際用的space, dd: 逐bit copy)

1. Node端:

``` sh
# 1. 建立目標 VM 映像目錄（如果還沒建立）
mkdir -p /var/lib/vz/images/121/

# 2. 直接轉換並輸出到目標資料夾
qemu-img convert -f raw -O qcow2 -c /dev/pve/vm-110-disk-2 /var/lib/vz/images/121/vm-110-disk-2.qcow2

# 3. 驗證檔案是否存在
ls -lh /var/lib/vz/images/121/

# 4. Cli 新增硬碟 or UI <your_VM> -> Hardware -> Add (UI可能找不到)
qm set 121 -scsi1 local:121/vm-110-disk-2.qcow2
```

2. VM 端:

``` bash
ssh mbvmtest0 #

## 0. 前置檢查指令 (選1)
lsblk                        # 查看系統目前的磁碟與分割區（確認 sdb1 存在）
sudo fdisk -l /dev/sd[a-z]      # 檢查 /dev/sdb 分割表與格式資訊（確保 sdb1 有格式化）

## 1. mount
sudo mkdir -p /mnt/sdb       # 建立 mount point
sudo mount /dev/sdb1 /mnt/sdb  # 將 /dev/sdb1 分割區掛載到 /mnt/sdb 資料夾

# 取得 UUID
UUID=$(sudo blkid -s UUID -o value "$PARTITION")

# 備份並修改 /etc/fstab
echo "👉 設定 /etc/fstab 自動掛載..."
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i "\|$MOUNT_POINT|d" /etc/fstab  # 移除舊的掛載記錄（相同掛載點）
echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults  0  2" | sudo tee -a /etc/fstab

df -h /mnt/sdb               # 確認是否成功掛載
ls /mnt/sdb                  # 檢查掛載後資料夾中是否有內容（驗證是否正常讀寫）

## 2. check

sudo nano /mnt/sdb/omg.txt

```
![alt text](image.png)

# OP1: #2. 調整






掛載

### 0. UI 新增 VM disk

- 目標VM > Hardware > Add > 選擇 Hard Disk > 選擇實體 storage >新增

### 0.1 於 VM 中查看掛載點

```bash
sudo fdisk -l
```

### 1. 重新用 `fdisk` 建立一個單一分割區

```bash
sudo fdisk /dev/sdb
```

依序執行以下操作：

* `n`：新增分割區
* `p`：主分割區
* `1`：第一個分割
* 按兩次 Enter：使用整顆磁碟
* `w`：寫入並退出

---

### 2. 格式化成 ext4 檔案系統 (只對空白 disk !!!)

```bash
sudo mkfs.ext4 /dev/sdb1
```

---

### 3. 建立並掛載

```bash
sudo mkdir -p /mnt/data
sudo mount /dev/sdb1 /mnt/data
```

---

### 4. 驗證

```bash
df -h | grep /mnt/data
```


```bash
sudo blkid /dev/sdb1
```



### Script



## vmdump

![alt text](image-3.png)

