git init
git add .
git commit -m "Initial commit"

git remote add origin {gitrepo} # git remote set-url origin {gitrepo}
git remote add public https://github.com/martinyeh0121/network-monitoring_prometheus.git
git remote add private https://github.com/martinyeh0121/network-monitoring_prometheus_private.git

git branch -m master main # 重命名本地分支


git push -u origin main # 推送到遠程 main 分支
git push -u public main
git push -u private main