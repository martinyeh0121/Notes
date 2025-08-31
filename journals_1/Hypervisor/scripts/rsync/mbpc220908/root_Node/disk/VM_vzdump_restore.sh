# vzdump 100 --mode snapshot --storage local --compress zstd
# qmrestore /var/lib/vz/dump/vzdump-qemu-100-2025_06_30-.vma.zst 200 --storage local-lvm
# vzdump --dumpdir /backup --mode stop --all

#!/bin/bash

read -p "請輸入要備份的 VM ID: " backup_id
read -p "請輸入重建的新 VM ID (input invalid 不重建): " restore_id

WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_LOG="$WORKDIR/vzdump_error.log"

# 備份 VM，錯誤重定向到日誌
if ! vzdump $backup_id --mode snapshot --storage local --compress zstd 2>"$BACKUP_LOG"; then
  echo "備份失敗！請查看錯誤訊息： $BACKUP_LOG"
  exit 1
else
  echo "備份成功"
fi

# 找最新備份檔名
ZSTNAME=$(find /var/lib/vz/dump/ -maxdepth 1 -type f -name "vzdump-qemu-${backup_id}-*.zst" -print0 | xargs -0 ls -t | head -1)

# 如果輸入valid ID 才執行還原
if [[ "$restore_id" =~ ^[0-9]+$ ]]; then
  if ! qmrestore "$ZSTNAME" "$restore_id" 2>$WORKDIR/qmrestore_error.log; then
    echo "還原失敗！請查看錯誤訊息： $WORKDIR/qmrestore_error.log"
    exit 1
  else
    echo "已備份 VM $backup_id 並還原為 VM $restore_id"
  fi
else
  echo "未輸入有效 VM ID，不執行還原"
fi

# --storage local-lvm

# qm snapshot 100 100_1 --description "Backup test"
