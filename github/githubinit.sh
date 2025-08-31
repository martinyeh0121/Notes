ls -la ~/.ssh
# ssh-keygen -t rsa -b 4096 -C "你的GitHub郵箱" # set pwd , -f ~/.ssh/id_rsa_github (可選, 後續路徑記得調整)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_mygithub -C "martin007004@gmail.com"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_mbgithub -C "martinyeh@mobagel.com"

eval "$(ssh-agent -s)" # 啟用 ssh-agent（一般系統預設會啟）

ssh-add ~/.ssh/id_rsa_mygithub    # 加入金鑰並輸入一次密碼，之後整個 session（開機期間）都不用再輸入密碼
cat ~/.ssh/id_rsa_mygithub.pub  # 複製此公鑰到 github 

ssh-add ~/.ssh/id_rsa_mbgithub    # 加入金鑰並輸入一次密碼，之後整個 session（開機期間）都不用再輸入密碼
cat ~/.ssh/id_rsa_mbgithub.pub  # 複製此公鑰到 github 

ssh -T git@github.com # yes

# init project 步驟參閱 gitinit.bash
# git remote set-url origin git@github.com:martinyeh0121/notes.git
