#!/bin/bash
# report - 风险分析报告生成

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

MODULE="report"

# 尝试读取缓存
cached=$(cache_get "$MODULE" "$COMPANY" "$CACHE_TTL_REPORT") && {
    echo "$cached"
    exit 0
}

log_info "正在生成 ${COMPANY} 的风险分析报告..."

# 读取各子模块的缓存数据
news_data=$(cache_get "news" "$COMPANY" "$CACHE_TTL_NEWS" 2>/dev/null) || news_data=""
risk_data=$(cache_get "risk" "$COMPANY" "$CACHE_TTL_RISK" 2>/dev/null) || risk_data=""
finance_data=$(cache_get "finance" "$COMPANY" "$CACHE_TTL_FINANCE" 2>/dev/null) || finance_data=""

# 统计各模块数据量
news_count=0
risk_count=0
finance_count=0
if [[ -n "$news_data" ]]; then
    news_count=$(echo "$news_data" | grep -c '^ *[0-9]' 2>/dev/null) || news_count=0
fi
if [[ -n "$risk_data" ]]; then
    risk_count=$(echo "$risk_data" | grep -c '^ *-' 2>/dev/null) || risk_count=0
fi
if [[ -n "$finance_data" ]]; then
    finance_count=$(echo "$finance_data" | grep -c '^ *-' 2>/dev/null) || finance_count=0
fi

# 生成报告头部
output="# ${COMPANY} 风险分析报告"$'\n'
output+=$'\n'
output+="生成时间: $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
output+=$'\n'
output+="---"$'\n'
output+=$'\n'

# 执行摘要
output+="## 执行摘要"$'\n'
output+=$'\n'
output+="本报告基于公开信息对 **${COMPANY}** 进行综合风险分析。"$'\n'
output+="数据覆盖: 新闻动态(${news_count}条)、风险事件(${risk_count}条)、财务信息(${finance_count}条)。"$'\n'
output+=$'\n'

# 新闻舆情分析
output+="## 新闻舆情分析"$'\n'
output+=$'\n'
if [[ -n "$news_data" ]]; then
    output+="${news_data}"$'\n'
else
    output+="暂无新闻数据，请先运行 news/fetch.sh"$'\n'
fi
output+=$'\n'

# 风险事件分析
output+="## 风险事件分析"$'\n'
output+=$'\n'
if [[ -n "$risk_data" ]]; then
    output+="${risk_data}"$'\n'
else
    output+="暂无风险数据，请先运行 risk/check.sh"$'\n'
fi
output+=$'\n'

# 财务分析
output+="## 财务分析"$'\n'
output+=$'\n'
if [[ -n "$finance_data" ]]; then
    output+="${finance_data}"$'\n'
else
    output+="暂无财务数据，请先运行 finance/fetch.sh"$'\n'
fi
output+=$'\n'

# 综合评估
output+="## 综合评估"$'\n'
output+=$'\n'
output+="| 维度 | 权重 | 数据量 |"$'\n'
output+="|------|------|--------|"$'\n'
output+="| 财务风险 | 30% | ${finance_count}条 |"$'\n'
output+="| 运营风险 | 25% | - |"$'\n'
output+="| 法律风险 | 20% | ${risk_count}条 |"$'\n'
output+="| 市场风险 | 15% | ${news_count}条 |"$'\n'
output+="| 声誉风险 | 10% | - |"$'\n'
output+=$'\n'

# 结论与建议
output+="## 结论与建议"$'\n'
output+=$'\n'
output+="1. 持续关注企业新闻动态和舆情变化"$'\n'
output+="2. 定期更新风险评估数据"$'\n'
output+="3. 重点关注已识别的风险事项"$'\n'
output+=$'\n'
output+="---"$'\n'
output+="*本报告由 wuwenzixun 自动生成，仅供参考*"$'\n'

# 写入缓存并输出
echo "$output" | cache_set "$MODULE" "$COMPANY"
echo "$output"
log_info "报告生成完成"
