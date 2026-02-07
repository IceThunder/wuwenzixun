#!/bin/bash
# news - 企业新闻抓取脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

COMPANY="${1:-}"
LIMIT="${2:-10}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\" [条数]"
    exit 1
fi

MODULE="news"

# 尝试读取缓存
cached=$(cache_get "$MODULE" "$COMPANY" "$CACHE_TTL_NEWS") && {
    echo "$cached"
    exit 0
}

log_info "正在抓取 ${COMPANY} 的最新新闻..."

encoded=$(url_encode "${COMPANY}")

# 抓取百度新闻
fetch_baidu_news() {
    local url="https://www.baidu.com/s?wd=${encoded}+最新新闻&rn=${LIMIT}"
    local html
    html=$(http_get "$url") || return 1

    echo "$html" | grep -oE '<h3[^>]*>.*</h3>' | while IFS= read -r line; do
        local title
        title=$(echo "$line" | strip_html | sed 's/^[[:space:]]*//')
        [[ -n "$title" && ${#title} -gt 4 ]] && echo "$title"
    done
}

# 抓取搜狗新闻作为补充
fetch_sogou_news() {
    local url="https://www.sogou.com/sogou?query=${encoded}+最新新闻&ie=utf8"
    local html
    html=$(http_get "$url") || return 1

    echo "$html" | grep -oE '<h3[^>]*>.*</h3>' | while IFS= read -r line; do
        local title
        title=$(echo "$line" | strip_html | sed 's/^[[:space:]]*//' | sed 's/|.*$//')
        [[ -n "$title" && ${#title} -gt 6 ]] && echo "$title"
    done
}

# 汇总：合并去重，限制条数
news_list=$(
    { fetch_baidu_news 2>/dev/null; fetch_sogou_news 2>/dev/null; } \
    | sort -u | head -n "$LIMIT"
)
count=$(echo "$news_list" | grep -c '.' 2>/dev/null || echo 0)

# 格式化输出
output="## ${COMPANY} - 新闻动态"$'\n'
output+=$'\n'
output+="抓取时间: $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
output+=$'\n'

if [[ "$count" -gt 0 ]]; then
    idx=1
    while IFS= read -r title; do
        output+="${idx}. ${title}"$'\n'
        idx=$((idx + 1))
    done <<< "$news_list"
    output+=$'\n'
    output+="共获取 ${count} 条新闻"$'\n'
else
    output+="未获取到相关新闻"$'\n'
fi

# 写入缓存并输出
echo "$output" | cache_set "$MODULE" "$COMPANY"
echo "$output"
log_info "新闻抓取完成，共 ${count} 条"
