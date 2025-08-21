## 使用情形

結論: 很久沒有修改，實際運作 workflow 3條，只有 Email 比較重要


``` yaml
workflows:
  # -- 表示幾乎沒用 workflow
  active:
    always_run:
      Email:
        - decanter AI reset password 通知
        - action AI send analytic report
        - 傳送 gmail 綁定 help@mobagel.com (•••• ••• •55, ken's phone 二階段驗證)
      web_monitor: # martin
        - 看公司網頁 http 回應狀態(6 urls) error > graylog (分開部署) > slack  # 5m
      PVE_QA_cluster: # martin
        - 抓 pve01 資料 > postgres (分開部署) # 5m

    no_history_last_month:
      - ken # 1 month, (看 execusion log)
      - report AI # 1 month, --
      - albert # 半年前, (暫時demo用)

  inactive: # 使用的人(根據 人/服務名)
    services:
      - Report AI # 1 month
      - decanter + action AI
    users:  
      - martin 
      - brian lin # 3 week, ()
      - irys # 1-2 week, ()
      - ken # 1 month, (看 execusion log)
      - albert # 半年前, (暫時demo用)

```

## 搬移

建議

1. 直接搬 

- 資料夾打包帶走 + 刪掉 wf/credential

2. 重啟容器

- n8n export 指令 + 刪掉 wf/credential


p.s. 2. 目前只搬 workflow, 登入憑證，無 log 紀錄 