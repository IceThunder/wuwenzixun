# wuwenzixun 配置文件

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# HTTP 请求配置
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
REQUEST_TIMEOUT=15
REQUEST_RETRY=3
REQUEST_DELAY=1

# 日志级别: debug | info | warn | error
LOG_LEVEL="info"

# 缓存过期时间（秒）
CACHE_TTL_NEWS=3600        # 新闻缓存 1 小时
CACHE_TTL_RISK=86400       # 风险缓存 24 小时
CACHE_TTL_FINANCE=43200    # 财务缓存 12 小时
CACHE_TTL_REPORT=43200     # 报告缓存 12 小时
CACHE_TTL_OUTLOOK=86400    # 展望缓存 24 小时

# API配置 (如需使用第三方API)
SEARCH_API=""
NEWS_API=""
