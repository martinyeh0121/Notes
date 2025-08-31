#!/bin/bash

read -p "請輸入遠端使用者名稱: " REMOTE_USER
read -p "請輸入遠端主機IP: " REMOTE_HOST
read -s -p "請輸入遠端使用者密碼: " REMOTE_PASS
echo

# 先產生遠端腳本檔案
cat > remote_install.sh <<'EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "📦 更新套件索引..."
apt-get update -y

echo "📥 安裝 SNMP、SNMPD ..."
apt-get install -y snmp snmpd -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

cat > /etc/snmp/snmpd.conf <<'EOF2'
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
EOF2

systemctl enable snmpd
systemctl restart snmpd
EOF

# 用 sshpass 傳送並執行，分配 tty
sshpass -p "$REMOTE_PASS" scp remote_install.sh ${REMOTE_USER}@${REMOTE_HOST}:/tmp/
sshpass -p "$REMOTE_PASS" ssh -t -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "echo $REMOTE_PASS | sudo -S bash /tmp/remote_install.sh"

# 清理本地暫存腳本
rm remote_install.sh
