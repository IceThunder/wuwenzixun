#!/bin/bash
# wuwenzixun - 企业风险分析主入口

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# 解析参数
COMPANY=""
DEPTH="$ANALYSIS_DEPTH"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --depth) DEPTH="$2"; shift 2 ;;
        --help) COMPANY=""; break ;;
        *) [[ -z "$COMPANY" ]] && COMPANY="$1"; shift ;;
    esac
done

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  🏢 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

show_help() {
    echo "用法: $0 \"公司名称\" [选项]"
    echo ""
    echo "选项:"
    echo "  --depth full    深度分析（耗时较长）"
    echo "  --depth normal  标准分析（默认）"
    echo "  --depth quick   快速概览"
    echo "  --help          显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 \"腾讯\" --depth normal"
    echo "  $0 \"阿里巴巴\" --full"
}

if [[ -z "$COMPANY" ]]; then
    show_help
    exit 0
fi

echo ""
print_header "🏢 企业风险分析系统"
echo ""
echo -e "  📍 目标企业: ${YELLOW}$COMPANY${NC}"
echo -e "  📊 分析深度: ${YELLOW}$DEPTH${NC}"
echo -e "  ⏰ 分析时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 步骤1: 新闻抓取
print_header "步骤1/5 - 新闻资讯抓取"
bash "${SCRIPT_DIR}/news/fetch.sh" "$COMPANY"
echo ""

# 步骤2: 风险检索
print_header "步骤2/5 - 风险信息检索"
bash "${SCRIPT_DIR}/risk/check.sh" "$COMPANY"
echo ""

# 步骤3: 财务抓取
print_header "步骤3/5 - 财务数据抓取"
bash "${SCRIPT_DIR}/finance/fetch.sh" "$COMPANY"
echo ""

# 步骤4: 报告生成
print_header "步骤4/5 - 风险分析报告"
bash "${SCRIPT_DIR}/report/generate.sh" "$COMPANY"
echo ""

# 步骤5: 未来展望
print_header "步骤5/5 - 未来展望建议"
bash "${SCRIPT_DIR}/outlook/predict.sh" "$COMPANY"
echo ""

print_header "✅ 分析完成"
echo ""
echo -e "${GREEN}所有子技能执行完毕！${NC}"
echo ""
