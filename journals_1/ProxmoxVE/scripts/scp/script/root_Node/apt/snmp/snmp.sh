#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "請以 root 權限執行"
   exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y snmp snmpd


cat > /etc/snmp/snmpd.conf << 'EOF'
sysLocation    Data Center Rack 3
# 設定系統所在位置為「Data Center Rack 3」

sysContact     Admin <admin@example.com>
# 設定系統管理者聯絡資訊為「Admin <admin@example.com>」

sysServices    72
# 系統服務類型代碼，72 表示系統所提供的服務類型（SNMP標準中的一個數值）

master  agentx
# 啟用 AgentX 代理協定，允許多個子代理與主代理通訊

agentaddress  udp:161
# 設定 SNMP 代理監聽 UDP 埠 161（SNMP 預設通訊埠）

view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.2
view   systemonly  included   .1.3.6.1.2.1.6
view   systemonly  included   .1.3.6.1.2.1.7
view   systemonly  included   .1.3.6.1.2.1.25
view   systemonly  included   .1.3.6.1.4.1.2021
# 定義名為 systemonly 的視圖，包含特定的 MIB OID 範圍（例如系統、介面、TCP、UDP、Host Resources 和 UCD-SNMP MIB）

rocommunity public
# 定義一個讀取社群名稱為 public 的 SNMP v1/v2c 只讀權限社群

rocommunity6 public default -V systemonly
# 定義一個 IPv6 的讀取社群名稱為 public，使用 systemonly 視圖（只允許存取該視圖範圍）

rouser authPrivUser authpriv -V systemonly
# 定義一個 SNMP v3 使用者名稱為 authPrivUser，使用認證與加密（authPriv）安全模式，且限定只讀 systemonly 視圖

includeDir /etc/snmp/snmpd.conf.d
# 包含 /etc/snmp/snmpd.conf.d 目錄下的其他配置檔案
EOF

systemctl enable snmpd
systemctl restart snmpd

needrestart -b

# if [ -f /var/run/reboot-required ]; then
#     echo "系統需要重啟，正在重啟..."
#     reboot
# else
#     echo "安裝與設定完成，無需重啟。"
# fi
