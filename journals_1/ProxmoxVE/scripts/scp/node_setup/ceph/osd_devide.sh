# 先將原磁碟全清空
wipefs -a /dev/sda
# sgdisk --zap-all /dev/sda

# root@mbpc220908:/etc/pve# lsblk
# NAME                                                                           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda                                                                              8:0    0   3.6T  0 disk 
# └─ceph--fef09708--5a14--4055--ad5c--c1e6fb7ac260-osd--block--d3d9d2d8--2cbb--4866--bcc6--eaff75460c1f
# 直接移除 dmsetup 
## dmsetup ls
# dmsetup remove ceph--fef09708--5a14--4055--ad5c--c1e6fb7ac260-osd--block--d3d9d2d8--2cbb--4866--bcc6--eaff75460c1f



# 建立 GPT 分區表
sgdisk --zap-all /dev/sda
parted /dev/sda mklabel gpt

# 假設磁碟 100G，建立兩個 50G 分區
parted -a optimal /dev/sda mkpart primary 0% 50%
parted -a optimal /dev/sda mkpart primary 50% 100%

#  ceph osd crush add-bucket osd_group1 host
# ceph osd crush rm osd_group1

ceph osd df
# !!!!!!! 重要  !!!!!!!  務必先查看當前版本指令設定
ceph osd crush --help  
# osd crush rule create-replicated <name> <root> <type> [<class>]
ceph osd crush rule create-replicated replicated_ssd_fast default host ssd_fast
# ceph osd crush rule ls

ceph osd pool create ssd_fast_pool  replicated_ssd_fast

ceph osd pool get <pool_name> crush_rule

ceph osd pool ls detail

ceph osd getcrushmap -o crushmap.bin
crushtool -d crushmap.bin -o crushmap.txt

