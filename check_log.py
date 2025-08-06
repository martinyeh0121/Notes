import re
from datetime import datetime

filename = "log.txt"
fmt = "%Y-%m-%d %H:%M:%S.%f"

with open(filename, "r", encoding="utf-8") as f:
    lines = [line.strip() for line in f if line.strip()]

prev_time = None
for idx, line in enumerate(lines):
    try:
        curr_time = datetime.strptime(line, fmt)
    except Exception as e:
        print(f"Line {idx+1} 格式錯誤: {line}")
        continue

    if prev_time is not None:
        diff = (curr_time - prev_time).total_seconds()
        if not 0.1 <= diff <= 0.2:
            print(f"第 {idx} 行與第 {idx+1} 行間隔 {diff:.3f} 秒，落在 0.1~0.2 秒之間")
            

            
    original_line = line  # 保留原始行做報錯時輸出用
    line = line.strip()   # 去除前後空白

    # 檢查是否只包含合法的時間格式字符
    if not re.match(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3,6}$', line):
        print(f"⚠️ 第 {idx+1} 行格式異常或含有異常字符: '{original_line}'")
        continue

    try:
        curr_time = datetime.strptime(line, fmt)
    except Exception as e:
        print(f"❌ 第 {idx+1} 行轉換錯誤: '{original_line}'，錯誤原因: {e}")
        continue

    prev_time = curr_time