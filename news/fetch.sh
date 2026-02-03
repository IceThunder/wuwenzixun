#!/bin/bash

# news - 企业新闻抓取脚本

COMPANY="${1:-}"
LIMIT="${2:-10}"

if [[ -z "$COMPANY" ]]; then
    echo "用法: $0 \"公司名称\" [条数]"
    exit 1
fi

echo "📰 正在抓取 $COMPANY 的最新新闻..."

# 使用百度新闻搜索
curl -s "https://www.baidu.com/s?wd=${COMPANY}+新闻&pn=5" | grep -oP '(?<=<title>).*?(?=</title>)' | head -$LIMIT

echo ""
echo "✅ 共获取 $(($LIMIT)) 条新闻"
