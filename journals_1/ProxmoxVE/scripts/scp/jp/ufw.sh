## 本地

# sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp comment "SSH psudo"

sudo ufw allow 22 comment 'SSH'
sudo ufw allow 443 comment 'HTTPS'
sudo ufw allow 4200 comment 'Dashboard Flow'
sudo ufw allow 32475 comment 'Longhorn'
sudo ufw allow 32555 comment '後台管理'
sudo ufw allow 32009 comment '服務埠'
sudo ufw allow 27017 comment 'MongoDB 資料庫'
sudo ufw allow 5432 comment 'PostgreSQL 資料庫'
sudo ufw allow 6006 comment 'Report AI Debug Log'
sudo ufw allow 5433 comment 'Report AI 資料庫'

sudo ufw allow from 192.168.0.0/16 to any port 8001 comment 'report ai'
sudo ufw allow from 192.168.0.0/16 to any port 8002 comment 'report ai'
sudo ufw allow from 192.168.0.0/16 to any port 3001 comment 'report ai'
sudo ufw allow from 192.168.0.0/16 to any port 3005 comment 'report ai'
sudo ufw allow from 192.168.0.0/16 to any port 15588 comment 'SSH'


# .service

ExecStart=/usr/bin/autossh -M 0 -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -i /root/.ssh/id_ed25519_host1 \
  -R 10022:localhost:15588 \
  -R 10080:localhost:80 \
  -R 10443:localhost:443 \
  -R 14200:localhost:4200 \
  -R 42475:localhost:32475 \
  -R 42555:localhost:32555 \
  -R 42009:localhost:32009 \
  -R 37017:localhost:27017 \
  -R 15432:localhost:5432 \
  -R 56006:localhost:6006 \
  -R 55433:localhost:5433 \
  root@35.187.213.232



## 跳板
sudo ufw allow 10022 comment 'SSH 管理 (對應 22)'
sudo ufw allow 10080 comment 'HTTP (對應 80)'
sudo ufw allow 10443 comment 'HTTPS (對應 443)'
sudo ufw allow 14200 comment 'Dashboard (對應 4200)'
sudo ufw allow 42475 comment 'Longhorn (對應 32475)'
sudo ufw allow 42555 comment '後台管理 (對應 32555)'
sudo ufw allow 42009 comment '服務埠 (對應 32009)'
sudo ufw allow 37017 comment 'MongoDB (對應 27017)'
sudo ufw allow 15432 comment 'PostgreSQL (對應 5432)'
sudo ufw allow 56006 comment 'Report AI Debug Log (對應 6006)'
sudo ufw allow 55433 comment 'Report AI 資料庫 (對應 5433)'
