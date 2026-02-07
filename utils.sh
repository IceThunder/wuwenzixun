#!/bin/bash
# wuwenzixun 公共函数库

# 加载配置
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"

# ============ 日志函数 ============

# 日志级别数值（兼容 Bash 3.2）
_log_level_num() {
    case "$1" in
        debug) echo 0 ;; info) echo 1 ;; warn) echo 2 ;; error) echo 3 ;; *) echo 1 ;;
    esac
}

log() {
    local level="$1"
    shift
    local msg="$*"
    local current_level
    current_level=$(_log_level_num "${LOG_LEVEL}")
    local msg_level
    msg_level=$(_log_level_num "${level}")

    if [[ "$msg_level" -ge "$current_level" ]]; then
        local color=""
        local label
        label=$(echo "$level" | tr '[:lower:]' '[:upper:]')
        case "$level" in
            debug) color="\033[0;37m" ;;
            info)  color="\033[0;32m" ;;
            warn)  color="\033[0;33m" ;;
            error) color="\033[0;31m" ;;
        esac
        echo -e "${color}[$(date '+%H:%M:%S')] [${label}] ${msg}\033[0m" >&2
    fi
}

log_debug() { log debug "$@"; }
log_info()  { log info "$@"; }
log_warn()  { log warn "$@"; }
log_error() { log error "$@"; }

# ============ URL 编码 ============

url_encode() {
    local string="$1"
    python3 -c "import urllib.parse; print(urllib.parse.quote('$string'))" 2>/dev/null \
        || echo "$string" | curl -Gso /dev/null -w '%{url_effective}' --data-urlencode @- '' | cut -c3-
}

# ============ HTTP 请求 ============

http_get() {
    local url="$1"
    local retry="${REQUEST_RETRY:-3}"
    local timeout="${REQUEST_TIMEOUT:-15}"
    local delay="${REQUEST_DELAY:-1}"

    for ((i=1; i<=retry; i++)); do
        log_debug "HTTP GET (第${i}次): $url"
        local response
        response=$(curl -sL \
            --max-time "$timeout" \
            -H "User-Agent: ${USER_AGENT}" \
            -H "Accept: text/html,application/xhtml+xml" \
            -H "Accept-Language: zh-CN,zh;q=0.9" \
            "$url" 2>/dev/null)

        if [[ $? -eq 0 && -n "$response" ]]; then
            echo "$response"
            return 0
        fi
        log_warn "请求失败，${delay}秒后重试..."
        sleep "$delay"
    done

    log_error "请求失败（已重试${retry}次）: $url"
    return 1
}

# ============ HTML 清理 ============

strip_html() {
    sed -e 's/<[^>]*>//g' \
        -e 's/&nbsp;/ /g' \
        -e 's/&amp;/\&/g' \
        -e 's/&lt;/</g' \
        -e 's/&gt;/>/g' \
        -e 's/&quot;/"/g' \
        -e "s/&#39;/'/g" \
        -e 's/&hellip;/…/g' \
        -e 's/  */ /g' \
        -e '/^[[:space:]]*$/d'
}

# ============ 缓存机制 ============

# 确保缓存目录存在
ensure_cache_dir() {
    local module="$1"
    local dir="${CACHE_DIR}/${module}"
    mkdir -p "$dir"
    echo "$dir"
}

# 生成缓存文件路径
cache_path() {
    local module="$1"
    local key="$2"
    local dir
    dir=$(ensure_cache_dir "$module")
    local hash
    hash=$(echo -n "$key" | md5 2>/dev/null | tail -1 | awk '{print $NF}')
    if [[ -z "$hash" ]]; then
        hash=$(echo -n "$key" | md5sum 2>/dev/null | cut -d' ' -f1)
    fi
    echo "${dir}/${hash}"
}

# 读取缓存（未过期则输出内容并返回0，否则返回1）
cache_get() {
    local module="$1"
    local key="$2"
    local ttl="$3"
    local file
    file=$(cache_path "$module" "$key")

    if [[ -f "$file" ]]; then
        local now file_time age
        now=$(date +%s)
        file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
        age=$((now - file_time))
        if [[ "$age" -lt "$ttl" ]]; then
            log_debug "缓存命中: ${module}/${key} (${age}s/${ttl}s)"
            cat "$file"
            return 0
        fi
        log_debug "缓存过期: ${module}/${key} (${age}s/${ttl}s)"
    fi
    return 1
}

# 写入缓存
cache_set() {
    local module="$1"
    local key="$2"
    local file
    file=$(cache_path "$module" "$key")
    cat > "$file"
    log_debug "缓存写入: ${module}/${key}"
}
