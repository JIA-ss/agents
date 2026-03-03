#!/usr/bin/env bash
# [已废弃] 请使用统一部署脚本: devops/deploy-macos.sh 或 devops/deploy-windows.bat
# 该脚本现在只是一个兼容性包装，调用新的统一部署脚本

echo "⚠️  此脚本已废弃，请使用统一部署脚本："
echo "   macOS/Linux: ./devops/deploy-macos.sh"
echo "   Windows:     devops\\deploy-windows.bat"
echo ""
echo "正在调用统一部署脚本..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/../devops/deploy-macos.sh"
