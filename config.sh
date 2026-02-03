# wuwenzixun 配置文件

# 分析深度: quick | normal | full
ANALYSIS_DEPTH="normal"

# 关注的行业领域
INDUSTRIES=(
    "科技"
    "金融"
    "制造业"
    "医疗"
    "房地产"
)

# 风险评估权重
WEIGHTS=(
    "financial:0.3"
    "operational:0.25"
    "legal:0.2"
    "market:0.15"
    "reputational:0.1"
)

# 输出格式: text | json | markdown
OUTPUT_FORMAT="markdown"

# 缓存目录
CACHE_DIR="$HOME/.cache/wuwenzixun"

# API配置 (如需使用第三方API)
SEARCH_API=""
NEWS_API=""
