#!/bin/bash
# finance - 企业财务信息抓取

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

MODULE="finance"

# 尝试读取缓存
cached=$(cache_get "$MODULE" "$COMPANY" "$CACHE_TTL_FINANCE") && {
    echo "$cached"
    exit 0
}

log_info "正在抓取 ${COMPANY} 的财务信息..."

encoded=$(url_encode "${COMPANY}")

# 搜索财务相关信息
search_finance() {
    local keyword="$1"
    local url="https://www.baidu.com/s?wd=${encoded}+${keyword}&rn=5"
    local html
    html=$(http_get "$url") || return 1

    echo "$html" | grep -oE '<h3[^>]*>.*?</h3>' | while IFS= read -r line; do
        local title
        title=$(echo "$line" | strip_html | sed 's/^[[:space:]]*//')
        [[ -n "$title" && ${#title} -gt 4 ]] && echo "  - ${title}"
    done
}

# 根据维度获取关键词
get_finance_keywords() {
    case "$1" in
        "财报数据") echo "财报 年报 季报" ;;
        "营收利润") echo "营收 净利润 毛利率" ;;
        "资产负债") echo "资产负债率 总资产 负债" ;;
        "业绩动态") echo "业绩预告 业绩快报 盈利" ;;
    esac
}

# 逐维度检索
output="## ${COMPANY} - 财务信息"$'\n'
output+=$'\n'
output+="抓取时间: $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
output+=$'\n'

for dimension in "财报数据" "营收利润" "资产负债" "业绩动态"; do
    keywords=$(get_finance_keywords "$dimension")
    output+="### ${dimension}"$'\n'
    output+=$'\n'

    dim_results=""
    for kw in $keywords; do
        results=$(search_finance "$kw" 2>/dev/null)
        if [[ -n "$results" ]]; then
            dim_results+="${results}"$'\n'
        fi
    done

    if [[ -n "$dim_results" ]]; then
        output+="${dim_results}"
    else
        output+="  未检索到相关信息"$'\n'
    fi
    output+=$'\n'
done

# 写入缓存并输出
echo "$output" | cache_set "$MODULE" "$COMPANY"
echo "$output"
log_info "财务信息抓取完成"
