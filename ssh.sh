ls -la ~/.ssh
ssh-keygen -t rsa -b 4096 -C "你的GitHub郵箱" # set pwd
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub  # 複製此公鑰

ssh -T git@github.com # yes
git remote set-url origin git@github.com:martinyeh0121/notes.git
git push -u origin main
