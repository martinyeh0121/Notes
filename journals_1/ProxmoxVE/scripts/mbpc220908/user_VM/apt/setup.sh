#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "請以 root 權限執行"
   exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "📦 更新套件索引..."
apt-get update -y
echo "📥 安裝 SNMP、SNMPD 與 wget、unzip、libsmi-tools..."

apt-get install -y \
    snmp \
    snmpd \
    wget \
    unzip \
    libsmi2-common \
    snmp-mibs-downloader \
    dos2unix \
    ncdu \
    ufw \
    sshpass \
    qemu-guest-agent \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"

# ================== snmp =============================

echo "📂 建立並配置 MIB 目錄..."
mkdir -p /usr/share/snmp/mibs/
# {ietf,iana,site}
# chmod -R 750 /usr/share/snmp/mibs

echo "🧬 設定 snmp.conf 啟用 MIB 支援..."

tee -a /etc/snmp/snmp.conf <<EOF
mibs +ALL
mibdirs /usr/share/snmp/mibs:/usr/share/snmp/mibs/ietf:/usr/share/snmp/mibs/iana:/usr/share/snmp/mibs/site
EOF

echo "🌐 下載常見 IETF / IANA MIB 檔案..."

download-mibs
 
mv /var/lib/mibs/* /usr/share/snmp/mibs ||\
echo -e '\033[33m[警告] 移動 MIB 檔案失敗，請檢查 /usr/share/snmp/mibs 是否存在 iana/, itef/。
此問題只會影響 MIB 名稱翻譯，不影響 SNMP 正常運作。\033[0m'


echo "🧹 移除 MIB 內多餘 CRLF 字元（轉 UNIX 格式）"
dos2unix /usr/share/snmp/mibs/**/*.MIB* /usr/share/snmp/mibs/**/*.txt &>/dev/null || true

# ================== snmpd ============================

echo "🛠️ 產生 snmpd.conf..."
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd_default.conf || true # 備份default

cat > /etc/snmp/snmpd.conf << 'EOF'
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
EOF

echo "🚀 啟用並重啟 SNMPD 服務..."
systemctl enable snmpd
systemctl restart snmpd

# ================== qemu-guest-agent ===================

echo "⚙️ 啟用 qemu-guest-agent..."
systemctl start qemu-guest-agent

# ================== ufw ================================

ufw disable

# ================== .bashrc ============================

# history ts
grep -q '^[^#]*HISTTIMEFORMAT="%F %T  "' ~/.bashrc || echo 'HISTTIMEFORMAT="%F %T  "' >> ~/.bashrc
source ~/.bashrc


echo "✅ 所有工具與服務安裝設定完成！"
echo "👉 可使用 snmpwalk, history | tail -1 測試"


