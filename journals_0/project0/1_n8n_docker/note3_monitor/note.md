
chmod
chown
ls 
-l
-ld
-s
-ltr 最新
-lSr 最大






// 動態更新 URI 和方法
requestConfig.uri = "https://api.newendpoint.com/data";
requestConfig.method = "POST";


method: 'get', // 'post', 'put', 'delete'
  url: 'https://example.com/api/v1/resource',
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  },
  timeout: 300000

## n8n 階段目標：
將以下 API call 的監控，加到 n8n 中
https://decanter.ai/v1/user
https://dxsign.ai/v1/user
https://decanter-fujitsu.mobagel.com/v1/user
https://wistron.mobagel.com/v1/user
https://bdx.mobagel.com/v1/user
請每隔五分鐘呼叫以上環境的 API (Get Method)
如果失敗(非200) 要發告警 slack channel p-0
不論成功或失敗，都要寫一筆資訊到 google sheet 中 做留存
### 
1. http header fields:
https://www.rfc-editor.org/rfc/rfc7235#section-4.2
Authorization field use API key

2. errors:
401
{
  "error": {
    "message": "401 - \"{\\\"message\\\":\\\"UNAUTHORIZED\\\",\\\"redirectTo\\\":\\\"/\\\",\\\"status\\\":\\\"ERROR\\\",\\\"status_code\\\":401}\\n\"",
    "name": "AxiosError",
    "stack": "AxiosError: Request failed with status code 401\n    at settle (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/settle.js:19:12)\n    at RedirectableRequest.handleResponse (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/adapters/http.js:547:9)\n    at RedirectableRequest.emit (node:events:531:35)\n    at RedirectableRequest._processResponse (/usr/local/lib/node_modules/n8n/node_modules/follow-redirects/index.js:409:10)\n    at ClientRequest.RedirectableRequest._onNativeResponse (/usr/local/lib/node_modules/n8n/node_modules/follow-redirects/index.js:102:12)\n    at Object.onceWrapper (node:events:634:26)\n    at ClientRequest.emit (node:events:519:28)\n    at HTTPParser.parserOnIncomingClient (node:_http_client:702:27)\n    at HTTPParser.parserOnHeadersComplete (node:_http_common:118:17)\n    at TLSSocket.socketOnData (node:_http_client:544:22)\n    at Axios.request (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/Axios.js:45:41)\n    at processTicksAndRejections (node:internal/process/task_queues:95:5)\n    at invokeAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:584:16)\n    at proxyRequestToAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:613:26)\n    at Object.request (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:1584:50)",
    "code": "ERR_BAD_REQUEST",
    "status": 401
  }
}
404
{
  "error": {
    "message": "404 - \"<!doctype html>\\n<html lang=en>\\n<title>404 Not Found</title>\\n<h1>Not Found</h1>\\n<p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>\\n\"",
    "name": "AxiosError",
    "stack": "AxiosError: Request failed with status code 404\n    at settle (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/settle.js:19:12)\n    at RedirectableRequest.handleResponse (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/adapters/http.js:547:9)\n    at RedirectableRequest.emit (node:events:531:35)\n    at RedirectableRequest._processResponse (/usr/local/lib/node_modules/n8n/node_modules/follow-redirects/index.js:409:10)\n    at ClientRequest.RedirectableRequest._onNativeResponse (/usr/local/lib/node_modules/n8n/node_modules/follow-redirects/index.js:102:12)\n    at Object.onceWrapper (node:events:634:26)\n    at ClientRequest.emit (node:events:519:28)\n    at HTTPParser.parserOnIncomingClient (node:_http_client:702:27)\n    at HTTPParser.parserOnHeadersComplete (node:_http_common:118:17)\n    at TLSSocket.socketOnData (node:_http_client:544:22)\n    at TLSSocket.emit (node:events:519:28)\n    at addChunk (node:internal/streams/readable:559:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:510:3)\n    at TLSSocket.Readable.push (node:internal/streams/readable:390:5)\n    at TLSWrap.onStreamRead (node:internal/stream_base_commons:191:23)\n    at TLSWrap.callbackTrampoline (node:internal/async_hooks:130:17)\n    at Axios.request (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/Axios.js:45:41)\n    at processTicksAndRejections (node:internal/process/task_queues:95:5)\n    at invokeAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:584:16)\n    at proxyRequestToAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:613:26)\n    at Object.request (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:1584:50)",
    "code": "ERR_BAD_REQUEST",
    "status": 404
  }
}
ENO
{
  "error": {
    "message": "getaddrinfo ENOTFOUND bdx.mobagle.com",
    "name": "Error",
    "stack": "Error: getaddrinfo ENOTFOUND bdx.mobagle.com\n    at Function.AxiosError.from (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/AxiosError.js:89:14)\n    at RedirectableRequest.handleRequestError (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/adapters/http.js:620:25)\n    at RedirectableRequest.emit (node:events:531:35)\n    at ClientRequest.eventHandlers.<computed> (/usr/local/lib/node_modules/n8n/node_modules/follow-redirects/index.js:49:24)\n    at ClientRequest.emit (node:events:519:28)\n    at emitErrorEvent (node:_http_client:101:11)\n    at TLSSocket.socketErrorListener (node:_http_client:504:5)\n    at TLSSocket.emit (node:events:519:28)\n    at emitErrorNT (node:internal/streams/destroy:169:8)\n    at emitErrorCloseNT (node:internal/streams/destroy:128:3)\n    at processTicksAndRejections (node:internal/process/task_queues:82:21)\n    at Axios.request (/usr/local/lib/node_modules/n8n/node_modules/axios/lib/core/Axios.js:45:41)\n    at processTicksAndRejections (node:internal/process/task_queues:95:5)\n    at invokeAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:584:16)\n    at proxyRequestToAxios (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:613:26)\n    at Object.request (/usr/local/lib/node_modules/n8n/node_modules/n8n-core/dist/NodeExecuteFunctions.js:1584:50)",
    "code": "ENOTFOUND",
    "status": null
  }
}

3. graphs
structures:
![flow v1](image-4.png)  
![flow v2](image-7.png)
slack node 本地部屬用 http post 搭配 webhook
(cloud n8n 的 slack node 可以直接帳號登入)
nodes flow:
![httpv1](image-2.png)
![http req v2](image-9.png)
![node excel](image.png)
respose parse:
![sheet input](image-12.png)
![response item](image-5.png)
![response item struct(401)](image-6.png)
![add uri/timestamp](image-11.png)
![error parser](image-13.png)       test case:401(no right key), 404(), EOT()
![if](image-3.png)
![parse v1](image-1.png): 401 error.message only, aborted
![slack webhook](image-15.png)
output:
![execusions](image-8.png)  ![slack api (cloud n8n)](image-10.png)
![output now](image-17.png)     ![output 0](image-14.png)

4. moniter簡述
**uri/key 可在 google sheet uri 中調整**
**google sheet history顯示監控紀錄，時間以schedule trigger node 的 timestamp為準**
**error 時會在 history 顯示 message 訊息並發 slack 通知**
**sheet row 背景變色待處理(預計用google sheet api, n8n node不支援)**


### js
1. 401 message parse 
<!-- // 處理轉譯符號
var Message = data
  .replace(/\\"/g, '"')
  .replace(/\\n/g, '')  
  .replace(/\\r/g, '')
// 提取 {} 範圍內容
const startIdx = Message.indexOf('{');
const endIdx = Message.lastIndexOf('}');
Message = Message.substring(startIdx, endIdx + 1);

//解析、新增屬性並輸出
const output=JSON.parse(Message);
output.type=$input.first().json.error.code;
return output; -->
2. error parser:
```javascript
return items.map(item => {
  try{    //4xx error
    const output={};
    output.timestamp=item.json.timestamp;
    output.uri=item.json.uri;
    const data = item.json.error;
    for (const key in data) {
      if (key!="stack" && key!="name")
        output[key] = data[key];
    }
    
    return output;

  } catch (error){    //other error (do flatten)
    const data = item.json;
    
    // 遍歷 JSON keys，動態生成平展的結構
    const flattenedData = {};
    flattenedData.timestamp=item.json.timestamp;
    flattenedData.uri=item.json.uri;
    for (const key in data) {
      if (Array.isArray(data[key])) {
        // 如果值是陣列，將其轉為逗號分隔的字串
        flattenedData[key] = data[key]
          .map(val => (typeof val === 'object' ? JSON.stringify(val) : val))
          .join(', ');
      } else if (typeof data[key] === 'object' && data[key] !== null) {
        // 如果值是物件，轉為字串
        flattenedData[key] = JSON.stringify(data[key]);
      } else {
        // 其他值直接存入
        flattenedData[key] = data[key];
      }
    }
    return { json: flattenedData };
  }
});
```

### 遷移
目前可逐個 workflow 複製貼上 (= download json & import)，Credentials部分需手動新增 

https://docs.n8n.io/external-secrets/#infisical-version-changes
https://docs.n8n.io/1-0-migration-checklist/#directory-for-installing-custom-nodes




# ai53:

#set the HOME environment variable (only Windows users need to execute this command)
#set HOME=%USERPROFILE%

curl -sSL https://raw.githubusercontent.com/OpenSPG/openspg/refs/heads/master/dev/release/docker-compose-west.yml -o docker-compose-west.yml
docker compose -f docker-compose-west.yml up -d

## Minio: Fatal glibc error: CPU does not support x86-64-v2
#image: spg-registry.us-west-1.cr.aliyuncs.com/spg/openspg-minio:latest # for only x86-64-v2
image: minio/minio:RELEASE.2024-01-18T22-51-28Z-cpuv1


# Wren:
![postgres匯入資料](image-16.png)
![頁面](image-20.png)
![log](image-18.png)
deploy (save) 時發現功能無法運行，看log發現 172.23.0.5:5555 連不上
172.23.0.5:5555 後來發現是 wren-ai-service-1 的docker ip
wren-ai-service-1 則由於 ![python 發生 KeyError](image-19.png)
目前待處理 
// cloud Wren
Titanic dataset
