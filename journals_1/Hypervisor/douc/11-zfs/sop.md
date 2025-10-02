
# ref
https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_time_synchronization
gpt

## 實際操作
``` sh
# 查看目前的磁碟與分割資訊，確認裝置名稱
lsblk

# 清除 /dev/nvme0n1 上的所有檔案系統簽名 (superblock, RAID metadata 等)
wipefs -a /dev/nvme0n1

# 清除 /dev/nvme1n1 上的所有檔案系統簽名
wipefs -a /dev/nvme1n1

# 建立一個名為 "main" 的 ZFS zpool，直接使用兩顆磁碟
zpool create main /dev/nvme1n1 /dev/nvme0n1
```


``` sh
# 條帶化 (Stripe) → RAID0 概念，至少 1 顆
zpool create fastpool /dev/sdX /dev/sdY

# 單顆磁碟 → 無容錯，直接使用
zpool create fastpool /dev/sdX

# 鏡像 (Mirror) → RAID1 概念，至少 2 顆
zpool create fastpool mirror /dev/sdX /dev/sdY

# RAID10 → 多組 Mirror 條帶化，至少 4 顆 (2 顆一組)
zpool create fastpool mirror /dev/sdX /dev/sdY mirror /dev/sdZ /dev/sdW
# (可再加 mirror vdev 組數：mirror /dev/sdA /dev/sdB ...)

# RAIDZ1 → 類似 RAID5，至少 3 顆，允許壞 1 顆
zpool create fastpool raidz /dev/sdX /dev/sdY /dev/sdZ

# RAIDZ2 → 類似 RAID6，至少 4 顆，允許壞 2 顆
zpool create fastpool raidz2 /dev/sdX /dev/sdY /dev/sdZ /dev/sdW

# RAIDZ3 → 類似 RAID7，至少 5 顆，允許壞 3 顆
zpool create fastpool raidz3 /dev/sdX /dev/sdY /dev/sdZ /dev/sdW /dev/sdV

```


``` sh 
zfs set compression=lz4 <pool or dataset>
zfs create -o compression=lz4 tank/mydata
zfs get compression,compressratio <dataset>

### !!!  -o
# ashift 選錯會造成效能浪費：
#    ashift=12：適用於現代 4K 磁碟（推薦）
#    ashift=9：適用於 512-byte 的老磁碟（不再常見）

```

| 類型 (ZFS vdev) | 對應 RAID           | 最少磁碟數          | 容錯能力     | 可用容量 (N 顆磁碟)  | 特點與用途               |
| ------------- | ----------------- | -------------- | -------- | ------------- | ------------------- |
| **單顆磁碟**      | RAID 0 (單碟)       | 1              | 無        | 100%          | 最簡單，沒有任何容錯          |
| **Stripe**    | RAID 0            | 2+             | 無        | 100%          | 高效能，壞一顆全毀           |
| **Mirror**    | RAID 1            | 2+ (偶數佳)       | 每組可壞 1 顆 | 50%（2 顆一組取一半） | 容錯強、讀取快，常見於重要資料     |
| **Mirror 多組** | RAID 10 (RAID1+0 = RAID1*N)    | 4+ (2 顆一組 ×2+) | 每組可壞 1 顆 | 50%           | 效能與容錯兼顧，適合 VM/DB    |
| **RAIDZ1**    | RAID 5            | 3+             | 可壞 1 顆   | (N-1)/N       | 容量效率好，但安全性不如 RAIDZ2 |
| **RAIDZ2**    | RAID 6            | 4+             | 可壞 2 顆   | (N-2)/N       | 最常用，效能/安全/容量均衡      |
| **RAIDZ3**    | （無直接對應，類似 RAID 7） | 5+             | 可壞 3 顆   | (N-3)/N       | 超高安全性，偏企業級大容量       |


