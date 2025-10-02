#!/bin/bash

# 自動寫入目前目錄到 .env
# if ! grep -q '^WORKDIR=' .env 2>/dev/null; then
#   echo "WORKDIR=$(pwd)" >> .env
# else
#   sed -i "s|^WORKDIR=.*$|WORKDIR=$(pwd)|" .env
# fi

# 讀取 .env
set -a
source .env
set +a

i=1
while true; do
  USER_HOST_VAR="USER_HOST${i}"
  KEY_NAME_VAR="KEY_NAME${i}"
  PASSWORD_VAR="PASSWORD${i}"
  NEWHOSTNAME_VAR="NEWHOSTNAME${i}"
  NEWPASSWORD_VAR="NEWPASSWORD${i}"

  USER_HOST="${!USER_HOST_VAR}"
  KEY_NAME="${!KEY_NAME_VAR}"
  PASSWORD="${!PASSWORD_VAR}"
  NEWHOSTNAME="${!NEWHOSTNAME_VAR}"
  NEWPASSWORD="${!NEWPASSWORD_VAR}"

  if [[ -z "$USER_HOST" || -z "$KEY_NAME" ]]; then
    break
  fi
  # 取得使用者名稱（@ 前的部分）
  USERNAME="${USER_HOST1%@*}"

  # 取得主機位址（@ 後的部分）
  HOST="${USER_HOST1#*@}"

  echo "=== 設定 $USER_HOST ($KEY_NAME) ==="

  # 初始化連線，執行 sshinit.sh
  # bash sshinit.sh "$USER_HOST" "$KEY_NAME" "$WORKDIR" "$PASSWORD"

  # 變更 hostname + 使用者密碼
  echo "=== 設定 hostname 與密碼 ==="

  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER_HOST" <<EOF
    echo "更改 hostname 為 $NEWHOSTNAME"
    sudo hostnamectl set-hostname $NEWHOSTNAME

    # echo "更改使用者密碼"
    # echo "$USERNAME:$NEWPASSWORD" | sudo chpasswd
EOF

  echo

  ((i++))
done
