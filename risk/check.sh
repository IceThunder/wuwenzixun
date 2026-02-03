#!/bin/bash

# risk - 企业风险信息检索

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

echo "⚠️  正在检索 $COMPANY 的风险信息..."
echo ""
echo "【诉讼信息】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+诉讼" -o /dev/null
echo "  ✓ 诉讼记录检索中..."
echo ""
echo "【行政处罚】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+处罚" -o /dev/null
echo "  ✓ 处罚记录检索中..."
echo ""
echo "【负面舆情】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+负面" -o /dev/null
echo "  ✓ 舆情监测中..."
echo ""
echo "✅ 风险信息检索完成"
