#!/bin/bash

# Deployment script for Flutter web app to greatyarmouthnails.com
# This script builds the Flutter app and uploads it to the server

set -e

echo "=========================================="
echo "Flutter Salon Owner App Deployment Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Clean and build
echo -e "${YELLOW}Step 1: Cleaning and building Flutter web app...${NC}"
flutter clean
rm -rf build/ pubspec.lock
flutter pub get
flutter build web --base-href="/owner/" --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build completed successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Build artifacts are ready in: build/web/${NC}"
echo ""

# Step 3: Display deployment instructions
echo -e "${YELLOW}========== NEXT STEPS ==========${NC}"
echo ""
echo "To deploy your app, you need to:"
echo ""
echo "1. Upload the contents of 'build/web/' to your server"
echo "   Location: /var/www/greatyarmouthnails.com/owner/ (or your web root)"
echo ""
echo "2. Key files to upload:"
echo "   - index.html"
echo "   - main.dart.js (contains all your changes)"
echo "   - flutter_bootstrap.js"
echo "   - flutter_service_worker.js"
echo "   - assets/ (entire folder)"
echo "   - canvaskit/ (entire folder)"
echo ""
echo "3. After uploading, clear your browser cache:"
echo "   - Chrome/Firefox: Ctrl+Shift+R (or Cmd+Shift+R on Mac)"
echo "   - Safari: Cmd+Option+R"
echo ""
echo "4. If using SSH, run:"
echo "   scp -r build/web/* user@greatyarmouthnails.com:/path/to/owner/"
echo ""
echo -e "${GREEN}Build is ready for deployment!${NC}"
echo ""
