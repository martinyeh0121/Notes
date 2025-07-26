# Cacti 架設與配置完整指南

## 目錄
1. [系統準備](#系統準備)
2. [Cacti 安裝](#cacti-安裝)
3. [MIB 檔案配置 (history，可略)](#mib-檔案配置-history可略)
4. [安裝 Spine Poller（又名 cactid, 使用C++)](#安裝-c-poller-cactidspine-步驟教學)
5. [Poller Interval（輪詢間隔）設定流程](#poller-interval輪詢間隔設定流程)
6. [網路設備自動發現](#網路設備自動發現)
7. [故障排除](#故障排除)
8. [常用指令速查](#常用指令速查)
9. [注意事項](#注意事項)

---

## 系統準備

### 基本系統配置
```bash
# 設定主機名稱
sudo hostname temp-it-1
sudo vim /etc/hostname

# 檢查系統時間
timedatectl

# 檢查磁碟空間
df -h

# 網路配置
sudo nano /etc/netplan/50-cloud-init.yaml
sudo netplan apply
ip a
```

### 安裝必要套件
```bash
# 安裝 Apache, MySQL, PHP 及相關套件
sudo apt install -y apache2 mariadb-server php php-mysql php-snmp php-gd php-xml php-mbstring php-intl libapache2-mod-php rrdtool snmp snmpd unzip

# 安裝 Cacti
sudo apt install -y cacti

# 安裝 SNMP MIB 下載器
sudo apt install snmp-mibs-downloader

# 安裝 nmap 用於網路掃描
sudo apt install nmap
```

---

## Cacti 安裝

### 資料庫配置
```bash
# 登入 MySQL
sudo mysql -u root -p

# 匯入 Cacti 資料庫結構
sudo mysql -u cactiuser -p cacti < /usr/share/cacti/cacti.sql
sudo mysql -u cactiuser -p cacti < /usr/share/cacti/conf_templates/cacti.sql

# 設定時區
sudo mysql_tzinfo_to_sql /usr/share/zoneinfo | sudo mysql -u root -p mysql
```

### PHP 配置
```bash
# 調整 PHP 記憶體限制和執行時間
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/max_execution_time = .*/max_execution_time = 60/' /etc/php/8.1/apache2/php.ini

# 檢查 PHP 時區設定
php -i | grep timezone
```

### MySQL 配置
```bash
# 編輯 MySQL 配置
sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf

# 重啟 MySQL 服務
sudo systemctl restart mariadb
```

### Cacti 檔案權限
```bash
# 設定 Cacti 目錄權限
sudo chown -R www-data:www-data /usr/share/cacti/site/
sudo chown -R www-data:www-data /usr/share/cacti/site/resource

# 建立 Apache 連結
sudo ln -s /usr/share/cacti /var/www/html/cacti

# 建立 Apache 配置
sudo nano /etc/apache2/conf-available/cacti.conf
```

### 服務啟動
```bash
# 啟用並啟動服務
sudo systemctl enable apache2 mariadb
sudo systemctl restart apache2 mariadb

# 設定 Cacti 排程
sudo vim /etc/cron.d/cacti
```

---

## MIB 檔案配置 (history，可略)

### 下載 Zyxel MIB 檔案
```bash
# 下載 Zyxel 交換器 MIB 檔案
curl -o XMG1930-30HP_7.zip https://download.zyxel.com/XMG1930-30HP/mib_file/XMG1930-30HP_7.zip

# 解壓縮並安裝 MIB 檔案
sudo unzip XMG1930-30HP_7.zip
sudo mv /usr/share/snmp/mibs/MIB/ZYXEL-*.mib /usr/share/snmp/mibs/
sudo rm -rf MIB/
```

### SNMP 配置
```bash
# 編輯 SNMP 配置
sudo nano /etc/snmp/snmpd.conf
sudo nano /etc/snmp/snmp.conf

# 重啟 SNMP 服務
sudo systemctl restart snmpd
```

### 測試 SNMP 連線
```bash
# 基本 SNMP 測試
snmpwalk -v2c -c public 192.168.5.102 system

# 使用特定 community string
snmpwalk -v2c -c snmp_zyxel 192.168.5.102 system

# 使用 MIB 檔案
snmpwalk -v2c -c snmp_zyxel -M +/usr/share/snmp/mibs -m ZYXEL-SYSTEM-MIB 192.168.5.102

# 測試特定 OID
snmptranslate -IR -On ZYXEL-SYS-MEMORY-MIB::zyxelSysMemUsage
```

---

## ✅ 安裝 C++ Poller（cactid/Spine）步驟教學

`cactid`（又稱為 C++ Poller 或 Spine）是 Cacti 的高效能 poller，用 **C++ 編寫**，比預設的 PHP `poller.php` 快很多，適合中大型部署。你可以透過安裝與設定 `cactid` 來提升 Cacti 的 poller 效率。

以下以 **Ubuntu/Debian 系統** 為例

---

### 🔧 第 1 步：安裝依賴套件

```bash
sudo apt update
sudo apt install -y build-essential libsnmp-dev libmysqlclient-dev libssl-dev libtool autoconf automake git
```

---

### 🔧 第 2 步：下載 Cacti 官方工具包（包含 cactid/Spine）

```bash
cd /opt
git clone https://github.com/Cacti/spine.git spine
cd spine
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install
```

這會安裝 C++ poller 可執行檔到 `/usr/local/spine/bin/spine`

---

### 🔧 第 3 步：設定 Spine（cactid）配置檔

```bash
sudo cp spine.conf.dist /etc/cacti/spine.conf
sudo nano /etc/cacti/spine.conf
```

設定內容如下（根據你的 Cacti DB 配置調整）：

```
DB_Host     localhost
DB_Database cacti
DB_User     cactiuser
DB_Password yourpassword
DB_Port     3306
DB_PreG     none

# 啟用多執行緒
Threads = 10
```

---

### 🔧 第 4 步：讓 Cacti 使用 Spine 作為 Poller

1. 登入 Cacti GUI
2. 前往：**Console → Configuration → Settings → Poller**
3. 找到「Poller Type」，選擇 `Spine`
4. 確認路徑 `/usr/local/spine/bin/spine` 正確
5. 儲存設定

---

### 🔧 第 5 步：測試是否能跑

在 CLI 下執行：

```bash
/usr/local/spine/bin/spine -V
```

應該會顯示版本資訊和基本設定測試。

你也可以執行一次輪詢測試：

```bash
/usr/local/spine/bin/spine  -V -R --debug
```

看有沒有錯誤出現。

---

### 🔧 第 6 步：確認系統正在使用 Spine

* 回到 Cacti 網頁首頁，Poller Info 應該會顯示使用 **Spine**
* `log/cacti.log` 中會出現類似：

```
SPINE: Poller[Main Poller] Time: 5.123s
```

代表正在使用 C++ Poller。

---

## PHP 版本管理  (已棄)

### 切換 PHP 版本
```bash
# 移除 PHP 8.1
sudo apt remove php8.1 php8.1-*

# 添加 PHP 7.4 儲存庫
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# 安裝 PHP 7.4
sudo apt install php7.4 php7.4-cli php7.4-common php7.4-mysql php7.4-snmp php7.4-xml php7.4-gd php7.4-curl php7.4-mbstring

# 切換 Apache PHP 模組
sudo a2dismod php8.1
sudo a2enmod php7.4
sudo systemctl restart apache2

# 設定 PHP 版本
sudo update-alternatives --config php
sudo update-alternatives --config phpize
sudo update-alternatives --config php-config
```

### 切換回 PHP 8.1
```bash
# 切換回 PHP 8.1
sudo a2dismod php7.4
sudo a2enmod php8.1
sudo systemctl restart apache2
```

---

## 網路設備自動發現

### 網路掃描
```bash
# 掃描 SNMP 設備
sudo nmap -sU -p 161 192.168.5.0/24 --open -oG ~/snmp_hosts_5.txt
sudo nmap -sU -p 161 192.168.16.0/24 --open -oG ~/snmp_hosts_1624.txt
```

### 自動添加設備腳本
```bash
# 建立自動添加腳本
nano auto_add_snmp_hosts.sh
chmod 750 auto_add_snmp_hosts.sh

# 執行腳本
sudo ./auto_add_snmp_hosts.sh
```

### 手動添加設備
```bash
# 使用 CLI 添加設備
sudo php /usr/share/cacti/cli/add_device.php \
    --description="test1" \
    --ip="192.168.16.62" \
    --template=5 \
    --version=2 \
    --community="public" \
    --port=161 \
    --timeout=500 \
    --ping_method=icmp \
    --quiet
```

---

## 故障排除

### 檢查服務狀態
```bash
# 檢查服務狀態
sudo systemctl status apache2 mariadb snmpd

# 檢查 Cacti 日誌
sudo tail -f /usr/share/cacti/site/log/cacti.log

# 檢查 Spine 日誌
sudo /usr/local/spine/bin/spine -V -R -C /etc/cacti/spine.conf
```

### 權限問題
```bash
# 檢查 Cacti 配置檔案權限
sudo cat /usr/share/cacti/site/include/config.php

# 重新設定權限
sudo chown -R www-data:www-data /usr/share/cacti/site/
```

### 資料庫連線
```bash
# 測試資料庫連線
mysql -u cactiuser -p cacti

# 檢查 Cacti 配置
sudo cat /etc/cacti/debian.php
```

### 網路連線測試
```bash
# 測試網路連線
ping 192.168.16.19

# 測試 SNMP 連線
snmpwalk -v2c -c public -t 1 -r 1 192.168.16.19 system
```

---

## 常用指令速查

### 系統管理
```bash
# 重啟系統
sudo shutdown -h now

# 檢查磁碟空間
df -h

# 檢查記憶體使用
free -h
```

### SNMP 工具 (後來透過 UI 進行 discovery)
```bash
# SNMP 查詢
snmpwalk -v2c -c public [IP] system
snmptranslate -IR -On [OID]

# 網路掃描
nmap -sU -p 161 [網段] --open
```

### Cacti 管理
```bash
# 執行 Cacti poller
php /usr/share/cacti/site/poller.php

# 添加設備
php /usr/share/cacti/cli/add_device.php [參數]

# 檢查 Cacti 狀態
sudo systemctl list-timers | grep cacti
```

---

## 注意事項

1. **PHP 版本相容性**: Cacti 對 PHP 版本有特定要求，建議使用 PHP 7.4 或 8.1
2. **MIB 檔案管理**: 定期清理重複的 MIB 檔案以避免衝突
3. **權限設定**: 確保 Cacti 目錄和檔案有正確的權限設定
4. **網路安全**: 使用適當的 SNMP community strings 和防火牆規則
5. **備份**: 定期備份 Cacti 資料庫和配置檔案

---


---

## Spine 權限補充

```bash
# 讓 spine 以 setuid root 執行，避免權限問題
sudo chmod u+s /usr/local/spine/bin/spine
```

---

## 🕒 Poller Interval（輪詢間隔）設定流程

Cacti 預設使用 cron 進行 poller 執行，若要更細緻的輪詢間隔（如 30 秒），建議改用 systemd timer 並調整資料庫設定。

### 1. 移除原本 cron 服務
```bash
sudo mv /etc/cron.d/cacti /etc/cron.d/cacti.disabled
```

### 2. 建立並啟用 systemd poller 服務與定時器

#### 建立 `/etc/systemd/system/cacti-poller.service`
```ini
[Unit]
Description=Cacti Poller Service

[Service]
Type=simple
User=www-data
ExecStart=/usr/bin/php /usr/share/cacti/site/poller.php
```

#### 建立 `/etc/systemd/system/cacti-poller.timer`
```ini
[Unit]
Description=Run Cacti Poller every 30 seconds

[Timer]
OnBootSec=30s
OnUnitActiveSec=30s
AccuracySec=1s
Unit=cacti-poller.service

[Install]
WantedBy=timers.target
```

#### 啟用並啟動 timer
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cacti-poller.timer
```

---

### 3. 資料庫操作（DB 操作）

> Cacti UI 的 cron_interval 只能選 1m/5m，若要 30 秒需手動改 DB，並避免前端改到設定

```sql
-- 進入資料庫
mysql -u cactiuser -p cacti

-- 查詢目前設定
SELECT name, value FROM settings WHERE name IN ('poller_interval', 'cron_interval', 'max_runtime');
-- 查詢範例輸出
+-----------------+-------+
| name            | value |
+-----------------+-------+
| cron_interval   | 300   |
| poller_interval | 30    |
+-----------------+-------+
2 rows in set (0.000 sec)

-- 修改 cron_interval 為 30 秒
UPDATE settings SET value = '30' WHERE name = 'cron_interval';
```

---

### 4. Poller/Timer 服務重啟
```bash
sudo systemctl restart cacti-poller.service cacti-poller.timer
```

---

### 5. 注意事項
- **poller_interval** 與 **cron_interval** 都需設為 30（秒），否則會有輪詢不同步問題。
- systemd timer 啟用後，cron 就不再需要，避免重複執行。
- 若有自訂 poller script 路徑，請同步調整 `ExecStart`。
