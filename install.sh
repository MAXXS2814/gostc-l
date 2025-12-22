#!/bin/bash

# 检查是否传入了参数
if [ -z "$1" ]; then
    echo "Usage: $0 <server|gostc> [additional arguments...]"
    exit 1
fi

# 获取脚本参数
TYPE=$1
shift  # 移除第一个参数，剩下的作为额外参数

# GitHub仓库信息
REPO_OWNER="MAXXS2814"
REPO_NAME="gostc-l"

# 目标目录
if [ "$TYPE" = "server" ]; then
    TARGET_DIR="/usr/local/gostc-admin"
    BINARY_NAME="server"
    INSTALL_COMMAND="service install"
elif [ "$TYPE" = "gostc" ]; then
    TARGET_DIR="/usr/local/bin"
    BINARY_NAME="gostc"
else
    echo "Invalid type. Use 'server' or 'gostc'."
    exit 1
fi

# 创建目标目录
sudo mkdir -p "$TARGET_DIR"

# 获取系统类型和架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# 架构转换
case "$ARCH" in
    "x86_64") ARCH="amd64" ;;
    "i686"|"i386") ARCH="386" ;;
    "aarch64"|"arm64") ARCH="arm64" ;;
    "armv7l"|"armv6l") ARCH="arm" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Windows 特殊处理
if [[ "$OS" == *"mingw"* || "$OS" == *"cygwin"* ]]; then
    OS="windows"
fi

# 获取最新 release
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest")

# 提取下载 URL
ASSETS=$(echo "$LATEST_RELEASE" | grep -oP '"browser_download_url": "\K.*?(?=")')

# 匹配文件：允许带版本号或不带版本号
MATCHED_FILE=""
for ASSET in $ASSETS; do
    BASENAME=$(basename "$ASSET")
    if [[ "$BASENAME" == ${TYPE}_${OS}_${ARCH}* ]]; then
        MATCHED_FILE="$ASSET"
        break
    fi
done

# 下载并解压
if [ -n "$MATCHED_FILE" ]; then
    FILE_NAME=$(basename "$MATCHED_FILE")
    echo "Downloading $FILE_NAME..."
    curl -L -o "$FILE_NAME" "$MATCHED_FILE"

    echo "Extracting $FILE_NAME to $TARGET_DIR..."
    if [[ "$FILE_NAME" == *.zip ]]; then
        sudo unzip -o "$FILE_NAME" -d "$TARGET_DIR"
    elif [[ "$FILE_NAME" == *.tar.gz ]]; then
        sudo tar -xzf "$FILE_NAME" -C "$TARGET_DIR"
    else
        echo "Unsupported file format: $FILE_NAME"
        exit 1
    fi

    # 找到二进制文件并修改权限
    if [[ -f "$TARGET_DIR/$BINARY_NAME" ]]; then
        sudo chown root:root "$TARGET_DIR/$BINARY_NAME"
        sudo chmod +x "$TARGET_DIR/$BINARY_NAME"
        echo "$BINARY_NAME installed successfully in $TARGET_DIR"
    else
        # 尝试匹配带版本号的二进制
        BIN_FILE=$(find "$TARGET_DIR" -maxdepth 1 -type f -name "${BINARY_NAME}*")
        if [ -n "$BIN_FILE" ]; then
            sudo chown root:root "$BIN_FILE"
            sudo chmod +x "$BIN_FILE"
            echo "$BINARY_NAME installed successfully in $TARGET_DIR as $(basename $BIN_FILE)"
        else
            echo "Binary $BINARY_NAME not found in $TARGET_DIR"
            exit 1
        fi
    fi

    # 如果是 server 类型，运行安装命令
    if [ "$TYPE" = "server" ]; then
        sudo "$TARGET_DIR/$BINARY_NAME" $INSTALL_COMMAND "$@"
    fi

    # 清理下载文件
    rm -f "$FILE_NAME"
else
    echo "No matching release file found for ${TYPE}_${OS}_${ARCH}"
fi
