#!/usr/bin/env bash
# OpenClaw quick health check - combines multiple status commands
# Usage: ./oc-health.sh [--json]

set -euo pipefail

JSON_MODE="${1:-}"

echo "=== OpenClaw Health Check ==="
echo ""

# 1. Gateway status
echo "--- Gateway ---"
if openclaw health ${JSON_MODE} 2>/dev/null; then
  echo "  Gateway: UP"
else
  echo "  Gateway: DOWN"
fi
echo ""

# 2. Channel status
echo "--- Channels ---"
openclaw status ${JSON_MODE} 2>/dev/null || echo "  Failed to get channel status"
echo ""

# 3. Model status
echo "--- Models ---"
openclaw models status 2>/dev/null || echo "  Failed to get model status"
echo ""

# 4. Cron status
echo "--- Cron ---"
openclaw cron status 2>/dev/null || echo "  Failed to get cron status"
echo ""

echo "=== Health Check Complete ==="
