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
CONFIG_FILE="$SCRIPT_DIR/upload_config.local"
BUNDLE_DIR="$HOME/Downloads/env-bootstrap-offline-bundle"
SSH_HOST_ALIAS=""
REMOTE_USER=""
REMOTE_HOST=""
REMOTE_DIR=""
SSH_PORT=""
IDENTITY_FILE=""

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)
            CONFIG_FILE="$2"
            if [ ! -f "$CONFIG_FILE" ]; then
                error "配置文件不存在: $CONFIG_FILE"
                exit 1
            fi
            source "$CONFIG_FILE"
            shift 2
            ;;
        --bundle-dir)
            BUNDLE_DIR="$2"
            shift 2
            ;;
        --host-alias)
            SSH_HOST_ALIAS="$2"
            shift 2
            ;;
        --user)
            REMOTE_USER="$2"
            shift 2
            ;;
        --host)
            REMOTE_HOST="$2"
            shift 2
            ;;
        --remote-dir)
            REMOTE_DIR="$2"
            shift 2
            ;;
        --port)
            SSH_PORT="$2"
            shift 2
            ;;
        --identity-file)
            IDENTITY_FILE="$2"
            shift 2
            ;;
        *)
            error "未知参数: $1"
            exit 1
            ;;
    esac
done

if ! command -v ssh >/dev/null 2>&1; then
    error "未找到 ssh"
    exit 1
fi

if ! command -v scp >/dev/null 2>&1; then
    error "未找到 scp"
    exit 1
fi

if [ ! -d "$BUNDLE_DIR" ]; then
    error "离线包目录不存在: $BUNDLE_DIR"
    exit 1
fi

if [ -z "$REMOTE_DIR" ]; then
    error "REMOTE_DIR 不能为空，请在配置文件或参数中指定"
    exit 1
fi

TARGET=""
if [ -n "$SSH_HOST_ALIAS" ]; then
    if [ -n "$REMOTE_USER" ]; then
        TARGET="${REMOTE_USER}@${SSH_HOST_ALIAS}"
    else
        TARGET="$SSH_HOST_ALIAS"
    fi
else
    if [ -z "$REMOTE_HOST" ]; then
        error "未设置 SSH_HOST_ALIAS 或 REMOTE_HOST"
        exit 1
    fi
    if [ -n "$REMOTE_USER" ]; then
        TARGET="${REMOTE_USER}@${REMOTE_HOST}"
    else
        TARGET="$REMOTE_HOST"
    fi
fi

SSH_CMD=(ssh)
SCP_CMD=(scp -r)

if [ -n "$SSH_PORT" ]; then
    SSH_CMD+=(-p "$SSH_PORT")
    SCP_CMD+=(-P "$SSH_PORT")
fi

if [ -n "$IDENTITY_FILE" ]; then
    SSH_CMD+=(-i "$IDENTITY_FILE")
    SCP_CMD+=(-i "$IDENTITY_FILE")
fi

REMOTE_DIR_CLEAN="${REMOTE_DIR%/}"
BUNDLE_BASENAME="$(basename "$BUNDLE_DIR")"
REMOTE_BUNDLE_PATH="${REMOTE_DIR_CLEAN}/${BUNDLE_BASENAME}"

info "创建远程目录: ${REMOTE_DIR_CLEAN}"
"${SSH_CMD[@]}" "$TARGET" "mkdir -p '$REMOTE_DIR_CLEAN'"

info "开始上传离线包目录到: ${TARGET}:${REMOTE_DIR_CLEAN}"
"${SCP_CMD[@]}" "$BUNDLE_DIR" "${TARGET}:${REMOTE_DIR_CLEAN}/"

info "上传完成"
info "服务器上可执行:"
echo "bash system/setup_system.sh --offline-bundle ${REMOTE_BUNDLE_PATH} --brew-prefix \$HOME/.linuxbrew"
