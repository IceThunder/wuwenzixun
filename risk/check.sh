#!/bin/bash
# risk - 企业风险信息检索

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

MODULE="risk"

# 尝试读取缓存
cached=$(cache_get "$MODULE" "$COMPANY" "$CACHE_TTL_RISK") && {
    echo "$cached"
    exit 0
}

log_info "正在检索 ${COMPANY} 的风险信息..."

encoded=$(url_encode "${COMPANY}")

# 搜索指定关键词，返回匹配的标题列表
search_risk() {
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

# 从搜索结果页提取大致结果数量
extract_result_count() {
    local keyword="$1"
    local url="https://www.baidu.com/s?wd=${encoded}+${keyword}"
    local html
    html=$(http_get "$url") || { echo "0"; return; }

    local count
    count=$(echo "$html" | grep -oE '百度为您找到相关结果约[0-9,]+个' | grep -oE '[0-9,]+' | head -1)
    echo "${count:-0}"
}

# 根据维度获取关键词
get_risk_keywords() {
    case "$1" in
        "诉讼风险") echo "诉讼 被告 起诉" ;;
        "行政处罚") echo "处罚 罚款 违规" ;;
        "失信信息") echo "失信 被执行 老赖" ;;
        "负面舆情") echo "负面 投诉 曝光" ;;
    esac
}

# 逐维度检索
output="## ${COMPANY} - 风险信息检索"$'\n'
output+=$'\n'
output+="检索时间: $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
output+=$'\n'

for dimension in "诉讼风险" "行政处罚" "失信信息" "负面舆情"; do
    keywords=$(get_risk_keywords "$dimension")
    output+="### ${dimension}"$'\n'
    output+=$'\n'

    dim_results=""
    for kw in $keywords; do
        results=$(search_risk "$kw" 2>/dev/null)
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

output+="### 风险等级评估"$'\n'
output+=$'\n'
output+="综合风险等级: 需结合详细数据进一步评估"$'\n'
output+="建议: 关注上述风险维度中出现的具体事项"$'\n'

# 写入缓存并输出
echo "$output" | cache_set "$MODULE" "$COMPANY"
echo "$output"
log_info "风险信息检索完成"
