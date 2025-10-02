#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "請以 root 權限執行"
   exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "📥 安裝 SNMP、SNMPD 相關 tools"
echo "🌐 下載常見 IETF / IANA MIB 檔案..."

apt-get install -y \
    snmp \
    snmpd \
    snmp-mibs-downloader \
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


# download-mibs
 
mv /var/lib/mibs/* /usr/share/snmp/mibs

echo "🧹 移除 MIB 內多餘 CRLF 字元（轉 UNIX 格式）"
dos2unix /usr/share/snmp/mibs/**/*.MIB* /usr/share/snmp/mibs/**/*.txt &>/dev/null || true

# ================== snmpd ============================

echo "🛠️ 產生 snmpd_example.conf..."

cat > /etc/snmp/snmpd_example.conf << 'EOF'
# ===============================================
# SNMP 設定檔：/etc/snmp/snmpd_example.conf
# 
# 使用方式（啟用流程）：
# 
# 1. 將本檔案複製為正式設定檔(原始生成 snmpd.conf 記得視需求備份)：
#      cp /etc/snmp/snmpd_example.conf /etc/snmp/snmpd.conf
#
# 2. 啟用並啟動 SNMP 服務：
#      systemctl enable snmpd
#      systemctl restart snmpd
#
# 3. 測試 SNMP 是否正常運作（使用 SNMPv2c）：
#      snmpwalk -v2c -c public localhost system
#
# ===============================================

# 設定 SNMP agent 的位置與聯絡人資訊
sysLocation    Data Center Rack 3       # 機房位置
sysContact     Admin <admin@example.com> # 聯絡人資訊

# 指定系統所提供的服務，72 = physical(4) + applications(64)
sysServices    72

# 啟用 agentx 協定，允許其他子代理（sub-agents）連接
master  agentx

# 設定 SNMP 監聽的地址和埠
agentaddress  udp:161

# 設定可讀取的 SNMP OID 視圖（View）
# systemonly 視圖只包含部分常見的 MIB 範圍
view   systemonly  included   .1.3.6.1.2.1.1     # system
view   systemonly  included   .1.3.6.1.2.1.2     # interfaces
view   systemonly  included   .1.3.6.1.2.1.6     # tcp
view   systemonly  included   .1.3.6.1.2.1.7     # udp
view   systemonly  included   .1.3.6.1.2.1.25    # host
view   systemonly  included   .1.3.6.1.4.1.2021  # ucdavis（CPU、記憶體等）

# 設定 community-based 存取
rocommunity public                         # IPv4 read-only community
rocommunity6 public default -V systemonly  # IPv6 read-only，限制在 systemonly 視圖

# 設定使用者存取（基於 SNMPv3）
rouser authPrivUser authpriv -V systemonly # SNMPv3 使用者，使用加密存取，限制視圖

# 引入其他子設定檔目錄
includeDir /etc/snmp/snmpd.conf.d

EOF

echo "✅ snmp安裝完成！"

