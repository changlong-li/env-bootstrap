#!/bin/bash

# 开启错误检查：如果某个命令失败，脚本不会立即退出，因为我们需要输出错误信息
set +e

# ==========================================
# 1. 基础打印函数配置 (带颜色高亮)
# ==========================================
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# ==========================================
# 2. 环境检查
# ==========================================
info "正在检查 Python 与 pip 环境..."

if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    error "未找到 pip，请先安装 Python 环境！"
    exit 1
fi

# 优先使用 pip3，如果不存在则使用 pip
PIP_CMD="pip3"
if ! command -v pip3 &> /dev/null; then
    PIP_CMD="pip"
fi

info "环境检查通过，准备开始安装依赖包..."

# ==========================================
# 3. 读取 packages.txt 并安装
# ==========================================
PACKAGE_FILE="packages.txt"

if [ ! -f "$PACKAGE_FILE" ]; then
    error "找不到 $PACKAGE_FILE 文件，请确保它和脚本在同一目录下！"
    exit 1
fi

info "开始逐个安装 $PACKAGE_FILE 中的包..."

while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    # 忽略空行和以 # 开头的注释行
    if [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # 去除首尾空格
    pkg=$(echo "$pkg" | xargs)
    
    $PIP_CMD install -U "$pkg" && info "[$pkg] 安装成功" || error "[$pkg] 安装失败"
done < "$PACKAGE_FILE"

# ==========================================
# 4. 初始化结束
# ==========================================
info "🎉 所有环境依赖已处理完毕！"
