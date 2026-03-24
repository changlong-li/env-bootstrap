#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/packages.txt"
BUNDLE_DIR="${1:-$SCRIPT_DIR/offline_bundle}"

if ! command -v brew >/dev/null 2>&1; then
    error "本地机器未检测到 Homebrew，无法准备离线包"
    exit 1
fi

if [ ! -f "$PACKAGE_FILE" ]; then
    error "未找到 $PACKAGE_FILE"
    exit 1
fi

mkdir -p "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/cache"

BREW_PREFIX="$(brew --prefix)"
BREW_CACHE="$(brew --cache)"

info "打包 Homebrew 前缀目录"
tar -czf "$BUNDLE_DIR/homebrew-prefix.tar.gz" -C "$BREW_PREFIX" .

info "预下载 system/packages.txt 中的 bottle"
while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    if [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    pkg=$(echo "$pkg" | xargs)
    HOMEBREW_NO_AUTO_UPDATE=1 brew fetch --force-bottle "$pkg"
done < "$PACKAGE_FILE"

info "拷贝 Homebrew 缓存到离线包目录"
cp -a "$BREW_CACHE/." "$BUNDLE_DIR/cache/"
cp "$PACKAGE_FILE" "$BUNDLE_DIR/packages.txt"

info "离线包准备完成: $BUNDLE_DIR"
