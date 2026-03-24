#!/bin/bash

set +e

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

if [ ! -f "$PACKAGE_FILE" ]; then
    error "未找到 $PACKAGE_FILE"
    exit 1
fi

if command -v pip3 &> /dev/null; then
    PIP_CMD="pip3"
elif command -v pip &> /dev/null; then
    PIP_CMD="pip"
else
    error "未找到 pip"
    exit 1
fi

info "开始安装 Python 包..."

while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    if [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    pkg=$(echo "$pkg" | xargs)
    $PIP_CMD install -U "$pkg" && info "[$pkg] 安装成功" || error "[$pkg] 安装失败"
done < "$PACKAGE_FILE"

info "Python 包安装完成"
