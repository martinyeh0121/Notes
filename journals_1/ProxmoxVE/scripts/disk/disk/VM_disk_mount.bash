#!/bin/bash

# default
MOUNT_POINT="/mnt/selected_disk"


read -p "請輸入 VM 的 SSH 位址（例如 user@mbvmtest0）: " SSH_TARGET

ssh -t "$SSH_TARGET" bash -c "' 
  echo \"目前系統磁碟與分割區列表：\"
  lsblk

  read -p \"請輸入要掛載的磁碟區（例如 /dev/sdb1）: \" PARTITION
  read -p \"請輸入要掛載的目錄 (預設 /mnt/selected_disk): \" USER_MOUNT_POINT

  if [ -n \"\$USER_MOUNT_POINT\" ]; then
    MOUNT_POINT=\$USER_MOUNT_POINT
  fi

  if [ ! -b \"\$PARTITION\" ]; then
    echo \"錯誤：磁碟區 \$PARTITION 不存在！\"
    exit 1
  fi

  echo \"建立掛載點 \$MOUNT_POINT...\"
  sudo mkdir -p \$MOUNT_POINT

  echo \"掛載磁碟區 \$PARTITION 到 \$MOUNT_POINT...\"
  sudo mount \$PARTITION \$MOUNT_POINT
cd
  echo \"掛載結果：\"
  df -h \$MOUNT_POINT
  ls \$MOUNT_POINT

  echo \"建立測試檔案 test.txt...\"
  echo \"這是測試內容\" | sudo tee \$MOUNT_POINT/test.txt
  echo \"✅ 完成掛載並建立檔案。\"
'"
