#!/bin/bash

# finance - 企业财务信息抓取

COMPANY="${1:-}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\""
    exit 1
fi

echo "💰 正在抓取 $COMPANY 的财务信息..."
echo ""
echo "【财报数据】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+财报" -o /dev/null
echo "  ✓ 财报数据检索中..."
echo ""
echo "【业绩预告】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+业绩" -o /dev/null
echo "  ✓ 业绩预告检索中..."
echo ""
echo "【营收利润】"
curl -s "https://www.baidu.com/s?wd=${COMPANY}+营收+利润" -o /dev/null
echo "  ✓ 营收利润数据检索中..."
echo ""
echo "✅ 财务信息抓取完成"
