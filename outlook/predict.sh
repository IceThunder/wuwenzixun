#!/bin/bash
# outlook - 未来展望建议

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

MODULE="outlook"

# 尝试读取缓存
cached=$(cache_get "$MODULE" "$COMPANY" "$CACHE_TTL_OUTLOOK") && {
    echo "$cached"
    exit 0
}

log_info "正在生成 ${COMPANY} 的未来展望..."

# 读取前序模块数据，用于辅助判断
news_data=$(cache_get "news" "$COMPANY" "$CACHE_TTL_NEWS" 2>/dev/null) || news_data=""
risk_data=$(cache_get "risk" "$COMPANY" "$CACHE_TTL_RISK" 2>/dev/null) || risk_data=""
finance_data=$(cache_get "finance" "$COMPANY" "$CACHE_TTL_FINANCE" 2>/dev/null) || finance_data=""

# 基于已有数据判断信息充足度
has_news="否"
has_risk="否"
has_finance="否"
[[ -n "$news_data" ]] && has_news="是"
[[ -n "$risk_data" ]] && has_risk="是"
[[ -n "$finance_data" ]] && has_finance="是"

# 统计风险条目数
risk_items=0
[[ -n "$risk_data" ]] && risk_items=$(echo "$risk_data" | grep -c '^\s*-' || echo 0)

# 生成展望报告
output="## ${COMPANY} - 未来展望报告"$'\n'
output+=$'\n'
output+="生成时间: $(date '+%Y-%m-%d %H:%M:%S')"$'\n'
output+=$'\n'
output+="数据基础: 新闻数据(${has_news}) | 风险数据(${has_risk}) | 财务数据(${has_finance})"$'\n'
output+=$'\n'

# 短期预测
output+="### 短期预测 (1-3个月)"$'\n'
output+=$'\n'
if [[ "$risk_items" -gt 10 ]]; then
    output+="- 风险关注度: 高（已识别 ${risk_items} 条风险信息）"$'\n'
    output+="- 建议: 密切关注风险事项进展，做好应对预案"$'\n'
elif [[ "$risk_items" -gt 0 ]]; then
    output+="- 风险关注度: 中等（已识别 ${risk_items} 条风险信息）"$'\n'
    output+="- 建议: 持续跟踪已识别风险，关注新增风险信号"$'\n'
else
    output+="- 风险关注度: 待评估（暂无风险数据）"$'\n'
    output+="- 建议: 建议先运行风险检索模块获取基础数据"$'\n'
fi
output+=$'\n'

# 中期展望
output+="### 中期展望 (3-12个月)"$'\n'
output+=$'\n'
output+="- 行业趋势: 需结合行业报告综合判断"$'\n'
output+="- 竞争态势: 关注同业动态和市场份额变化"$'\n'
output+="- 建议: 关注行业政策变化及监管动向"$'\n'
output+=$'\n'

# 长期趋势
output+="### 长期趋势 (1-3年)"$'\n'
output+=$'\n'
output+="- 发展空间: 需结合企业战略和行业前景评估"$'\n'
output+="- 风险因素: 宏观经济、政策监管、技术变革"$'\n'
output+="- 建议: 定期进行全面风险评估，建立长效监测机制"$'\n'
output+=$'\n'

# 行动建议
output+="### 行动建议"$'\n'
output+=$'\n'
output+="1. 持续监测企业新闻动态和舆情变化"$'\n'
output+="2. 关注行业政策和监管动向"$'\n'
output+="3. 定期更新风险评估（建议每月一次）"$'\n'
output+="4. 建立关键风险指标预警机制"$'\n'
output+="5. 对已识别风险制定应对预案"$'\n'
output+=$'\n'
output+="---"$'\n'
output+="*本展望基于公开信息生成，仅供参考*"$'\n'

# 写入缓存并输出
echo "$output" | cache_set "$MODULE" "$COMPANY"
echo "$output"
log_info "未来展望生成完成"
