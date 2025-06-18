

## n8n compose
/home/mobagel/mobagel/docker/n8n/n8nHost_Prod
1. n8n
* ./n8n_storage: logdata
* ./backup: 匯出credential / WF (跨db遷移用)
2. postgres
* ./db_storage: appdata (postgres)
3. backup 策略
* db_storage備份

## postgres