# ls -la ~/.ssh
# ssh-keygen -t rsa -b 4096 -C "你的GitHub郵箱" # set pwd , -f ~/.ssh/id_rsa_github (可選, 後續路徑記得調整)

# 檢查並生成個人 GitHub 金鑰
if [ ! -f ~/.ssh/id_rsa_mygithub ]; then
    echo "生成個人 GitHub 金鑰..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_mygithub -C "martin007004@gmail.com"
    echo "個人 GitHub 金鑰已生成"
    cat ~/.ssh/id_rsa_mygithub.pub
else
    echo "個人 GitHub 金鑰已存在，跳過生成"
    cat ~/.ssh/id_rsa_mygithub.pub
fi

# 檢查並生成公司 GitHub 金鑰
if [ ! -f ~/.ssh/id_rsa_mbgithub ]; then
    echo "生成公司 GitHub 金鑰..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_mbgithub -C "martinyeh@mobagel.com"
    echo "公司 GitHub 金鑰已生成"
    cat ~/.ssh/id_rsa_mbgithub.pub
else
    echo "公司 GitHub 金鑰已存在，跳過生成"
    cat ~/.ssh/id_rsa_mbgithub.pub
fi

eval "$(ssh-agent -s)" # 啟用 ssh-agent（一般系統預設會啟）

ssh-add ~/.ssh/id_rsa_mygithub    # 加入金鑰並輸入一次密碼，之後整個 session（開機期間）都不用再輸入密碼

# ssh-add ~/.ssh/id_rsa_mbgithub    # 加入金鑰並輸入一次密碼，之後整個 session（開機期間）都不用再輸入密碼

ssh -T git@github.com # yes

# init project 步驟參閱 gitinit.bash
# git remote set-url origin git@github.com:martinyeh0121/notes.git
