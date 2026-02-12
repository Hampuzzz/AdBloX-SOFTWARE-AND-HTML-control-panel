#!/bin/bash
# Deploy AdBloX MESH dashboard to mesh.adblox.se
# Usage: ./scripts/deploy-dashboard.sh [user@host]

set -euo pipefail

TARGET="${1:-root@mesh.adblox.se}"
REMOTE_PATH="/var/www/mesh.adblox.se"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DASHBOARD_DIR="$SCRIPT_DIR/../dashboard"

echo "==> Deploying AdBloX MESH dashboard"
echo "    Target: $TARGET:$REMOTE_PATH"
echo ""

rsync -avz --delete \
  --exclude '.DS_Store' \
  --exclude '*.swp' \
  "$DASHBOARD_DIR/" \
  "$TARGET:$REMOTE_PATH/"

echo ""
echo "==> Dashboard deployed successfully!"
echo "    URL: https://mesh.adblox.se"
