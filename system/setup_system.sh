#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/packages.txt"
ACTIVE_PACKAGE_FILE="$PACKAGE_FILE"
OFFLINE_BUNDLE=""
BREW_PREFIX_TARGET="${HOME}/.linuxbrew"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --offline-bundle)
            OFFLINE_BUNDLE="$2"
            shift 2
            ;;
        --brew-prefix)
            BREW_PREFIX_TARGET="$2"
            shift 2
            ;;
        *)
            error "未知参数: $1"
            exit 1
            ;;
    esac
done

if [ ! -f "$PACKAGE_FILE" ]; then
    error "未找到 $PACKAGE_FILE"
    exit 1
fi

find_brew_bin() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return 0
    fi
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        echo "/home/linuxbrew/.linuxbrew/bin/brew"
        return 0
    fi
    if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "/opt/homebrew/bin/brew"
        return 0
    fi
    if [ -x "${BREW_PREFIX_TARGET}/bin/brew" ]; then
        echo "${BREW_PREFIX_TARGET}/bin/brew"
        return 0
    fi
    return 1
}

brew_shellenv() {
    local brew_bin="$1"
    eval "$("$brew_bin" shellenv)"
}

is_online() {
    local targets=("https://github.com" "https://raw.githubusercontent.com" "https://ghcr.io")
    local t
    for t in "${targets[@]}"; do
        if ! curl -fsI --connect-timeout 4 --max-time 8 "$t" >/dev/null 2>&1; then
            return 1
        fi
    done
    return 0
}

install_brew_online() {
    info "检测到在线模式，开始安装 Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_brew_offline() {
    local bundle_dir="$1"
    if [ -z "$bundle_dir" ] || [ ! -d "$bundle_dir" ]; then
        error "离线模式需要有效目录: --offline-bundle <dir>"
        exit 1
    fi
    if [ ! -f "$bundle_dir/homebrew-prefix.tar.gz" ]; then
        error "离线目录缺少 homebrew-prefix.tar.gz"
        exit 1
    fi
    mkdir -p "$BREW_PREFIX_TARGET"
    tar -xzf "$bundle_dir/homebrew-prefix.tar.gz" -C "$BREW_PREFIX_TARGET"
    if [ -d "$bundle_dir/cache" ]; then
        export HOMEBREW_CACHE="$bundle_dir/cache"
    fi
    if [ -f "$bundle_dir/packages.txt" ]; then
        ACTIVE_PACKAGE_FILE="$bundle_dir/packages.txt"
    fi
}

install_packages() {
    local force_offline="$1"
    local pkg
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        if [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        pkg=$(echo "$pkg" | xargs)
        if [ "$force_offline" = "1" ]; then
            HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_FROM_API=1 brew install --force-bottle "$pkg" \
                && info "[$pkg] 安装成功" || error "[$pkg] 安装失败"
        else
            HOMEBREW_NO_AUTO_UPDATE=1 brew install "$pkg" \
                && info "[$pkg] 安装成功" || error "[$pkg] 安装失败"
        fi
    done < "$ACTIVE_PACKAGE_FILE"
}

if brew_bin="$(find_brew_bin)"; then
    brew_shellenv "$brew_bin"
    info "检测到 Homebrew: $brew_bin"
    install_packages "0"
    exit 0
fi

if [ -n "$OFFLINE_BUNDLE" ]; then
    info "未检测到 Homebrew，使用离线包安装"
    install_brew_offline "$OFFLINE_BUNDLE"
    brew_bin="$(find_brew_bin)"
    brew_shellenv "$brew_bin"
    install_packages "1"
    exit 0
fi

if is_online; then
    install_brew_online
    brew_bin="$(find_brew_bin)"
    brew_shellenv "$brew_bin"
    install_packages "0"
else
    warn "当前服务器无法访问 GitHub 相关站点"
    warn "请在本地联网机器执行: bash system/prepare_offline_bundle.sh /path/to/offline_bundle"
    warn "然后 scp 上传目录到服务器后执行:"
    warn "bash system/setup_system.sh --offline-bundle <服务器上的离线目录> --brew-prefix ${BREW_PREFIX_TARGET}"
    exit 1
fi
