# root@php73-test:/var/www
## cat ./generate_vhost.sh

#!/bin/bash
# 交互式輸入 Domain 前置
read -p "請輸入 Domain 前置：" SERVER_NAME
# 交互式輸入 DocumentRoot 目錄位置
read -p "請輸入目錄位置：" DOCUMENT_ROOT
# 將底線替換成破折號，以適應域名格式
DOMAIN_NAME=$(echo "$SERVER_NAME" | sed 's/_/-/g')
# 生成虛擬主機設定
VHOST_CONFIG="
<VirtualHost *:80>
    DocumentRoot \"/var/www/html/$DOCUMENT_ROOT\"
    ServerName $DOMAIN_NAME.labspace.com.tw
    ServerAlias www.$DOMAIN_NAME.labspace.com.tw
    ##tag by system @$DOMAIN_NAME $(date +%Y%m%d)#
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =www.$DOMAIN_NAME.labspace.com.tw [OR]
    RewriteCond %{SERVER_NAME} =$DOMAIN_NAME.labspace.com.tw
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
"
# 將設定內容顯示在終端機
echo "$VHOST_CONFIG"
# 將設定寫入到指定的檔案中，檔案名稱包含完整的域名
CONFIG_FILE="/etc/apache2/sites-available/$DOMAIN_NAME.labspace.com.tw.conf"
echo "$VHOST_CONFIG" | sudo tee "$CONFIG_FILE" > /dev/null
# 啟用網站並重新啟動 Apache
sudo a2ensite "$DOMAIN_NAME.labspace.com.tw.conf"
sudo systemctl reload apache2
echo "虛擬主機設定已成功生成並啟用：$CONFIG_FILE"
echo


# root@php73-test:/var/www
## cat update_ufw_home.sh

#!/bin/bash
# 交互式輸入 Domain 前置
read -p "請輸入目前家裡IP：" Home_ip
# 確認 IP 地址是否有效 (簡單的檢查)
if [[ ! "$Home_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "無效的 IP 地址: $Home_ip"
    exit 1
fi
# Define UFW rule description for identification
rule_desc="家裡臨時IP"
# Remove old rules associated with the rule description
ufw status numbered | grep "# $rule_desc" | awk '{print $2}' | tr -d '[]' | sort -r | xargs -I {} sh -c 'yes | ufw delete {}'
# Add a new rule for the current IP
ufw allow from "$Home_ip" to any port 22 comment "$rule_desc"
# Apply UFW changes
ufw reload
# root@php73-test:/var/www#