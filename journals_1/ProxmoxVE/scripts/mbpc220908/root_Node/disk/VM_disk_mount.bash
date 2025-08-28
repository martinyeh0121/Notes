#!/bin/bash

# default
MOUNT_POINT="/mnt/selected_disk"


read -p "請輸入 VM 的 SSH 位址（例如 user@mbvmtest0）: " SSH_TARGET

ssh -t "$SSH_TARGET" 'bash -s' <<'EOF'
echo "目前系統磁碟與分割區列表："
lsblk

read -p "請輸入要掛載的磁碟區（例如 /dev/sdb1）: " PARTITION
read -p "請輸入要掛載的目錄 (預設 /mnt/selected_disk): " USER_MOUNT_POINT

MOUNT_POINT="/mnt/selected_disk"
if [ -n "$USER_MOUNT_POINT" ]; then
  MOUNT_POINT="$USER_MOUNT_POINT"
fi

if [ ! -b "$PARTITION" ]; then
  echo "錯誤：磁碟區 $PARTITION 不存在！"
  exit 1
fi

echo "建立掛載點 $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"

echo "掛載磁碟區 $PARTITION 到 $MOUNT_POINT..."
sudo mount "$PARTITION" "$MOUNT_POINT"

UUID=$(sudo blkid -s UUID -o value "$PARTITION")
FSTYPE=$(sudo blkid -s TYPE -o value "$PARTITION")

if [ -z "$UUID" ] || [ -z "$FSTYPE" ]; then
  echo "❌ 無法取得 UUID 或檔案系統格式"
  exit 1
fi

echo "👉 備份並設定 /etc/fstab 自動掛載..."
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i "\|$MOUNT_POINT|d" /etc/fstab
sudo sed -i "\|UUID=$UUID|d" /etc/fstab
echo "UUID=$UUID  $MOUNT_POINT  $FSTYPE  defaults,nofail  0  2" | sudo tee -a /etc/fstab

echo "✅ 驗證掛載是否成功..."
if mountpoint "$MOUNT_POINT"; then
  echo "🎉 掛載成功："
  df -h "$MOUNT_POINT"
else
  echo "⚠️ 掛載失敗"
fi
EOF


# cd
#   echo \"掛載結果：\"
#   df -h \$MOUNT_POINT
#   ls \$MOUNT_POINT

#   echo \"建立測試檔案 test.txt...\"
#   echo \"這是測試內容\" | sudo tee \$MOUNT_POINT/test.txt
#   echo \"✅ 完成掛載並建立檔案。\"
