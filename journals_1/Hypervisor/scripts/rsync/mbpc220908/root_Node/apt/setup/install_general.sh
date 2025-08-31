#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "📥 安裝 wget、unzip、libsmi-tools..."

apt-get install -y \
    wget \
    unzip \
    libsmi2-common \
    dos2unix \
    ncdu \
    ufw \
    sshpass \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"

# ================== ufw ================================

ufw disable


echo "✅ 所有套件安裝設定完成！"

