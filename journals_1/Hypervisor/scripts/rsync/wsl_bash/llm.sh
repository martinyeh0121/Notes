#!/bin/bash

read -p "請輸入遠端使用者名稱: " REMOTE_USER
read -p "請輸入遠端主機IP: " REMOTE_HOST

ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo bash -s' << 'EOF'

export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
   echo "請以 root 權限執行"
   exit 1
fi

echo "📦 更新套件索引..."
apt-get update -y

echo "📥 安裝 SNMP、SNMPD 與 needrestart..."
apt-get install -y \
    snmp \
    snmpd \
    needrestart \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"

cat > /etc/snmp/snmpd.conf << 'EOC'
sysLocation    Data Center Rack 3
sysContact     Admin <admin@example.com>
sysServices    72
master  agentx
agentaddress  udp:161

view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.2
view   systemonly  included   .1.3.6.1.2.1.6
view   systemonly  included   .1.3.6.1.2.1.7
view   systemonly  included   .1.3.6.1.2.1.25
view   systemonly  included   .1.3.6.1.4.1.2021

rocommunity public
rocommunity6 public default -V systemonly
rouser authPrivUser authpriv -V systemonly

includeDir /etc/snmp/snmpd.conf.d
EOC

systemctl enable snmpd
systemctl restart snmpd

EOF
