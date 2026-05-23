#!/bin/bash

# FoodByte - Platform Master Setup
# Clones or updates all 8 repositories into a single workspace.
# Usage: bash setup.sh

set -e

GITHUB_USER="ansuman-satapathy"
BASE_DIR="foodbyte-platform"

echo "🚀 Initializing FoodByte Platform Workspace..."
mkdir -p "$BASE_DIR" && cd "$BASE_DIR"

repos=(
  "foodbyte-infra"
  "foodbyte-helm-charts"
  "foodbyte-gitops"
  "foodbyte-user-service"
  "foodbyte-order-service"
  "foodbyte-restaurant-service"
  "foodbyte-notification-service"
  "foodbyte-frontend"
)

for repo in "${repos[@]}"; do
  if [ -d "$repo" ]; then
    echo "🔄 $repo already exists, pulling latest..."
    git -C "$repo" pull
  else
    echo "📥 Cloning $repo..."
    git clone "https://github.com/$GITHUB_USER/$repo.git"
  fi
done

echo ""
echo "✅ Setup Complete. Workspace Structure:"
ls -1
echo ""
echo "🎯 Next Steps:"
echo "  1. Local Dev:   cd foodbyte-helm-charts && tilt up"
echo "  2. Production:  cd foodbyte-gitops && cat README.md"
