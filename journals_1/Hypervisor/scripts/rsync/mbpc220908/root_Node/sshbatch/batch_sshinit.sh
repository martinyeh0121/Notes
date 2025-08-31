#!/bin/bash

# # 自動寫入目前目錄到 .env
# if ! grep -q '^WORKDIR=' .env 2>/dev/null; then
#   echo "WORKDIR=$(pwd)" >> .env
# else
#   sed -i "s|^WORKDIR=.*$|WORKDIR=$(pwd)|" .env
# fi

# 設定 WORKDIR 為腳本目錄
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 讀取 .env
set -a
source .env
set +a

i=1
while true; do
  USER_HOST_VAR="USER_HOST${i}"
  KEY_NAME_VAR="KEY_NAME${i}"
  PASSWORD_VAR="PASSWORD${i}"
  USER_HOST="${!USER_HOST_VAR}"
  KEY_NAME="${!KEY_NAME_VAR}"
  PASSWORD="${!PASSWORD_VAR}"

  if [[ -z "$USER_HOST" || -z "$KEY_NAME" ]]; then
    break
  fi

  echo "=== 設定 $USER_HOST ($KEY_NAME) ==="
  bash sshinit.sh "$USER_HOST" "$KEY_NAME" "$PASSWORD" #"$WORKDIR"
  echo

  ((i++))
done 