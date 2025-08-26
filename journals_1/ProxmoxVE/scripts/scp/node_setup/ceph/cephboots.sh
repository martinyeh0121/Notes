# 備份符號連結檔案
mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bak

# 建立普通檔案供 cephadm 使用
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

read "是否覆寫原設定"

# 執行 cephadm bootstrap
cephadm bootstrap --mon-ip 192.168.16.62 --initial-dashboard-user admin --initial-dashboard-password mmo908bagel --allow-overwrite

# bootstrap 成功後
# 將 cephadm 新寫入的公鑰合併回原本檔案（視情況而定）
cat /root/.ssh/authorized_keys >> 

# 還原符號連結
rm /root/.ssh/authorized_keys
ln -s /etc/pve/priv/authorized_keys /root/.ssh/authorized_keys
