#!/bin/bash

set -e

#!/bin/bash
set -e

echo "停止所有 Ceph 服務..."
systemctl stop ceph-mgr@mbpc220908.service || true
systemctl stop ceph-mon.target || true
systemctl stop ceph-osd.target || true
systemctl stop ceph-mgr.target || true
systemctl stop ceph-mds.target || true
systemctl stop ceph-crash || true

echo "停用所有 Ceph 服務..."
systemctl disable ceph-mgr@mbpc220908.service || true
systemctl disable ceph-mon.target || true
systemctl disable ceph-osd.target || true
systemctl disable ceph-mgr.target || true
systemctl disable ceph-mds.target || true
systemctl disable ceph-crash || true

echo "停止 Ceph 相關 slice..."
systemctl stop system-ceph\x2dmgr.slice || true
systemctl stop system-ceph\x2dmon.slice || true
systemctl stop system-ceph\x2dvolume.slice || true

# echo "停用 Ceph 相關 slice..."
# systemctl disable system-ceph\x2dmgr.slice || true
# systemctl disable system-ceph\x2dmon.slice || true
# systemctl disable system-ceph\x2dvolume.slice || true


echo "殺掉所有 Ceph 相關進程..."
pkill ceph || true

echo "刪除 Ceph 相關資料與設定目錄..."
rm -rf /etc/ceph /var/lib/ceph /var/log/ceph

echo "清理完成，建議重啟系統"
