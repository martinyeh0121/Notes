

systemctl stop ceph.target
# cephadm rm-cluster --fsid $(cat /etc/ceph/ceph.client.admin.keyring | grep fsid | awk '{print $3}') --force
cephadm rm-cluster --fsid $(cat /etc/ceph/ceph.conf | grep fsid | awk '{print $3}') --force
rm -rf /etc/ceph /var/lib/ceph


# ########## 舊版移除 ############

# # 停止 Ceph 服務
# systemctl stop ceph-mon.target
# systemctl stop ceph-osd.target
# systemctl stop ceph-mgr.target
# systemctl stop ceph-mds.target
# systemctl stop ceph.target
# # systemctl stop ceph-radosgw.target

# # 移除 OSD
# ceph -s
# ceph osd tree
# ceph osd out <osd-id>
# ceph osd crush remove osd.<osd-id>
# ceph auth del osd.<osd-id>
# ceph osd rm <osd-id>

# # 移除 MON
# ceph mon remove <mon-name>

# # 移除 MGR
# ceph mgr dump  # 確認有哪些 mgr
# ceph mgr fail <mgr-id>
# ceph mgr module disable <mgr-id>
# ceph mgr module rm <mgr-id>

# # 移除 MDS
# ceph mds dump  # 確認有哪些 mds
# ceph mds fail <mds-id>
# ceph mds module disable <mds-id>
# ceph mds module rm <mds-id>

# # 清理殘留
# rm -rf /etc/ceph
# rm -rf /var/lib/ceph



# 改 crush map host 名稱
ceph osd crush rename-bucket <old-host> <new-host>


nano /etc/hosts

hostnamectl set-hostname mbpc220904

ceph osd crush rename-bucket mbpc220904 mbpctest04

corosync.conf