
rule "Extract host from n8n log message"
when
    has_field("message") &&
    contains(to_string($message.message), "n8nhost_worker")
then
    let msg = to_string($message.message);
    
    // 擷取 URL
    let url_match = regex(" (https?://[^\\s]+)", msg);
    let url = url_match["0"];
    set_field("log_url", url);

    // 嘗試擷取時間戳（格式：2025-05-06T12:34:56）
    let ts_match = regex("(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2})", to_string($message.message))["0"];
    let ts_match = replace(ts_match, "T", " ");
    set_field("log_ts", ts_match);
    
    
    //(.+?)([^\\s]+)
    let err_match = regex( "https.[^\\s]+ (.*?) error", msg)["0"];
    set_field("log_err", err_match);
    
    let exid_match = regex( "error (#.[^\\s]+)", msg)["0"];
    set_field("log_exid", exid_match);
    
    // regex_replace (\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}) -->  ($1)S($2) 整段替換 其他部分不動
    // let ts_match = regex_replace("(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2})", to_string($message.message), "$1 $2");



    // 可自訂來源 IP 或其他欄位
    set_field("localhost_ip", "192.168.16.19");
end

