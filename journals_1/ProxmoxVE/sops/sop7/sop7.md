
## hostname 更改流程 

### notice

> 記得預先 轉移 / dump node 的 VM 資料 (/var/lib/vz (local)會保留，/etc/pve (local-lvm)會清空)

> 確認移除 node 後 quorum 數量符合



### 從 cluster 上移除 node (若 node 連接 cluster)

1. 在 cluster 上其他 node 

``` sh
pvecm delnode $nodename
```


2. 在被移除 node

``` sh
# Step 1: 停止服務
systemctl stop pve-cluster corosync 

# Step 2: 啟動 pmxcfs 在本地模式（不使用 cluster）
pmxcfs -l

# Step 3: 刪除 cluster 和 corosync 設定（請小心！）
# rm -f /var/lib/pve-cluster/config.db*
rm -rf /var/lib/pve-cluster/*
rm -f /etc/pve/corosync.conf
rm -rf /var/lib/corosync/*
rm -rf /etc/corosync/*

# Step 4: 終止 pmxcfs 進程 & 重開機
killall -9 pmxcfs
```
### 舊 hostname 改成新 hostname

``` sh
hostnamectl set-hostname mbpc220905
nano /etc/hosts
```

### 完成以上動作後重啟

``` sh
reboot
```

### 最後加入新 host

``` sh
pvecm add $IP_of_the_healthy_Node_of_the_Cluster
```

![alt text](image.png)


### 完成hostname 更改


##