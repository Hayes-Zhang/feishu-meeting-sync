#!/bin/bash
# feishu-meeting-sync 安装脚本
# 安装 lark CLI（飞书中国版）并配置环境

set -e

echo "🔧 feishu-meeting-sync 安装脚本"
echo ""

# 检测系统
OS=$(uname -s)
ARCH=$(uname -m)

if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
    echo "❌ 暂不支持 $OS 系统，目前仅支持 macOS 和 Linux"
    exit 1
fi

# 确定 lark-cli 下载链接
LARK_VERSION="0.12.0"
if [ "$OS" = "Darwin" ] && [ "$ARCH" = "arm64" ]; then
    LARK_ARCHIVE="lark_${LARK_VERSION}_darwin_arm64.tar.gz"
elif [ "$OS" = "Darwin" ] && [ "$ARCH" = "x86_64" ]; then
    LARK_ARCHIVE="lark_${LARK_VERSION}_darwin_amd64.tar.gz"
elif [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    LARK_ARCHIVE="lark_${LARK_VERSION}_linux_amd64.tar.gz"
elif [ "$OS" = "Linux" ] && [ "$ARCH" = "aarch64" ]; then
    LARK_ARCHIVE="lark_${LARK_VERSION}_linux_arm64.tar.gz"
else
    echo "❌ 不支持的架构: $OS $ARCH"
    exit 1
fi

LARK_URL="https://github.com/yjwong/lark-cli/releases/download/v${LARK_VERSION}/${LARK_ARCHIVE}"
INSTALL_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.lark"

# 1. 下载 lark CLI
echo "📥 下载 lark CLI v${LARK_VERSION}..."
mkdir -p "$INSTALL_DIR"
curl -sL "$LARK_URL" | tar xz -C /tmp/
mv /tmp/lark "$INSTALL_DIR/lark"
chmod +x "$INSTALL_DIR/lark"

# 2. 修补飞书中国版域名（用 sed 替换二进制中的域名）
echo "🔧 适配飞书中国版..."
if command -v go &>/dev/null; then
    # 如果有 Go 环境，从 patch 目录编译
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -d "$SCRIPT_DIR/patch" ]; then
        echo "  从源码编译（需要 Go）..."
        cd /tmp
        git clone --depth 1 https://github.com/yjwong/lark-cli.git lark-cli-build 2>/dev/null || true
        cd lark-cli-build
        # 应用飞书域名补丁
        sed -i.bak 's|open.larksuite.com|open.feishu.cn|g' internal/api/client.go
        sed -i.bak 's|accounts.larksuite.com|accounts.feishu.cn|g' internal/auth/oauth.go
        sed -i.bak 's|open.larksuite.com|open.feishu.cn|g' internal/auth/oauth.go
        make build 2>/dev/null
        cp ./lark "$INSTALL_DIR/lark"
        cd /tmp && rm -rf lark-cli-build
        echo "  ✅ 编译完成"
    fi
else
    # 没有 Go，用 sed 直接改二进制（仅 macOS/Linux）
    # larksuite.com 和 feishu.cn 长度不同，用 null padding
    if [ "$OS" = "Darwin" ]; then
        LC_ALL=C sed -i '' 's/open\.larksuite\.com/open.feishu.cn\x00\x00\x00\x00/g' "$INSTALL_DIR/lark"
        LC_ALL=C sed -i '' 's/accounts\.larksuite\.com/accounts.feishu.cn\x00\x00\x00\x00\x00/g' "$INSTALL_DIR/lark"
    else
        sed -i 's/open\.larksuite\.com/open.feishu.cn\x00\x00\x00\x00/g' "$INSTALL_DIR/lark"
        sed -i 's/accounts\.larksuite\.com/accounts.feishu.cn\x00\x00\x00\x00\x00/g' "$INSTALL_DIR/lark"
    fi
    echo "  ✅ 二进制补丁完成"
fi

# 3. 安装 feishu-sync
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/feishu-sync" "$INSTALL_DIR/feishu-sync"
chmod +x "$INSTALL_DIR/feishu-sync"

# 4. 配置目录
mkdir -p "$CONFIG_DIR"

# 5. 提示配置环境变量
echo ""
echo "✅ 安装完成！"
echo ""
echo "接下来需要你做 3 件事："
echo ""
echo "1️⃣  添加环境变量到 ~/.zshrc（或 ~/.bashrc）："
echo ""
echo '   export PATH="$HOME/bin:$PATH"'
echo '   export LARK_CONFIG_DIR="$HOME/.lark"'
echo '   export LARK_APP_ID="你的飞书应用 App ID"'
echo '   export LARK_APP_SECRET="你的飞书应用 App Secret"'
echo ""
echo "2️⃣  创建飞书应用（如果还没有）："
echo "   打开 https://open.feishu.cn/app → 创建企业自建应用"
echo "   添加权限：docx:document:readonly, minutes:minutes:readonly, board:whiteboard:node:read 等"
echo "   安全设置 → 重定向 URL → 添加 http://localhost:9999/callback"
echo "   发布应用"
echo ""
echo "3️⃣  首次登录授权："
echo "   source ~/.zshrc && lark auth login --scopes minutes,documents"
echo ""
echo "之后就可以用了："
echo "   feishu-sync --today              # 同步今天的会议"
echo "   feishu-sync <飞书文档链接>        # 同步指定会议"
echo "   feishu-sync --list               # 查看已同步"
