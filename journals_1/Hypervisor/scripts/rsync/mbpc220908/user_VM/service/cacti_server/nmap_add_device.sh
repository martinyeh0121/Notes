#!/bin/bash

# ======== 設定區 ========
SUBNET="192.168.16.9/32"
COMMUNITY="public"
SNMP_VER="2c"

CACTI_CLI="/usr/share/cacti/cli/add_device.php"
DEVICE_TEMPLATE_ID=5  # ← 用 `--list-templates` 先查對 ID

# Optional: 如果你日後想用 CLI 做 auth，可以用這些變數登入 Cacti Web UI 或 API
# CACTI_USER="admin"
# CACTI_PASS="Mobagel*5355"

# ======== 掃描 SNMP 裝置 ========
echo "[*] Scanning subnet: $SUBNET ..."
nmap -sU -p 161 --open -oG snmp_hosts.txt "$SUBNET"

# ======== 擷取有 SNMP 開啟的 IP ========
echo "[*] Extracting hosts ..."
grep "161/open" snmp_hosts.txt | awk '{print $2}' > active_snmp_hosts.txt

# 檢查是否有找到任何裝置
if [ ! -s active_snmp_hosts.txt ]; then
    echo "[!] No SNMP hosts found. Exiting."
    exit 1
fi

# ======== 將裝置加入 Cacti ========
echo "[*] Adding hosts to Cacti ..."

while read -r HOST; do
    echo " [+] Testing SNMP on $HOST..."
    echo snmpwalk -v"$SNMP_VER" -c "$COMMUNITY" -t 1 -r 1 "$HOST" system

    if snmpwalk -v"$SNMP_VER" -c "$COMMUNITY" -t 1 -r 1 "$HOST" system > /dev/null 2>&1; then
        echo "     - SNMP ok, adding $HOST to Cacti..."

        # 嘗試取得主機名稱作為 Cacti 顯示名稱（可讀性更好）
        DESCRIPTION=$(snmpget -v"$SNMP_VER" -c "$COMMUNITY" -Ovq "$HOST" SNMPv2-MIB::sysName.0 2>/dev/null)
        [ -z "$DESCRIPTION" ] && DESCRIPTION="$HOST"

        # 實際加入設備到 Cacti
        php "$CACTI_CLI" \
            --description="$DESCRIPTION" \
            --ip="$HOST" \
            --template="$DEVICE_TEMPLATE_ID" \
            --version=2 \
            --community="$COMMUNITY" \
            --port=161 \
            --timeout=500 \
            --ping_method=icmp \
            --quiet

        echo "     - Added: $DESCRIPTION ($HOST)"
    else
        echo "     - SNMP failed on $HOST, skipping."
    fi
done < active_snmp_hosts.txt

echo "[*] Done."
