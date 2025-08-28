#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

# 抓取 hostname
HOSTNAME=$(hostname)

# 檢查是否包含 "vm"
if [[ "$HOSTNAME" == *vm* ]]; then
    echo "🖥️  主機名稱包含 'vm'，安裝 qemu-guest-agent..."

    apt-get install -y \
        qemu-guest-agent \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold"

    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent

    echo "✅ 安裝完成"
else
    echo "⚠️ 主機名稱不包含 'vm'，略過安裝 qemu-guest-agent"
fi
