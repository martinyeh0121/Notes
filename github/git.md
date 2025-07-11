好的，我來教你設定 SSH 方式，這樣更方便：

## 步驟 1：檢查是否已有 SSH Key

```bash
ls -la ~/.ssh
```

如果看到 `id_rsa` 和 `id_rsa.pub` 文件，說明已經有 SSH key。

## 步驟 2：生成 SSH Key（如果沒有）

```bash
ssh-keygen -t rsa -b 4096 -C "你的GitHub郵箱"
```

按 Enter 接受預設路徑，可以設定密碼（可選）。

## 步驟 3：啟動 SSH Agent

```bash
eval "$(ssh-agent -s)"
```

## 步驟 4：添加 SSH Key 到 Agent

```bash
ssh-add ~/.ssh/id_rsa
```

## 步驟 5：複製公鑰

```bash
cat ~/.ssh/id_rsa.pub
```

複製整個輸出內容。

## 步驟 6：添加到 GitHub

1. 去 GitHub.com → Settings → SSH and GPG keys
2. 點擊 "New SSH key"
3. **Title**: 輸入描述，例如 "My Computer"
4. **Key**: 貼上剛才複製的公鑰內容
5. 點擊 "Add SSH key"

## 步驟 7：測試 SSH 連接

```bash
ssh -T git@github.com
```

第一次會問是否信任，輸入 `yes`。

## 步驟 8：更改遠程倉庫地址

```bash
git remote set-url origin git@github.com:martinyeh0121/notes.git
```

## 步驟 9：推送代碼

```bash
git push -u origin main
```

現在就不需要輸入用戶名和密碼了！