git init
git add .
git commit -m "Initial commit"


### 多個 remote 設定
# 先清掉 origin
git remote remove origin

# 新增 origin 並設 fetch URL（通常就是主要倉庫）
git remote add origin git@github.com:avazakumo/Notes.git

# 加上多一個 push URL
git remote set-url --add --push origin git@github.com:avazakumo/Notes.git
git remote set-url --add --push origin git@github.com:martinyeh0121/Notes.git

# 設定 main 的 upstream（只要設定一次）
git branch --set-upstream-to=origin/main main


###
# git remote add origin {gitrepo} # git remote set-url origin {gitrepo}
# git remote add public https://github.com/martinyeh0121/network-monitoring_prometheus.git
# git remote add private https://github.com/martinyeh0121/network-monitoring_prometheus_private.git

# git branch -m master main # 重命名本地分支


# git push -u origin main # 推送到遠程 main 分支
# git push -u public main
# git push -u private main
