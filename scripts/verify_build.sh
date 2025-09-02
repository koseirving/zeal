#!/bin/bash

# Build verification script for App Store submission
# This script helps ensure the app is built correctly for production

echo "====================================="
echo "ZEAL Build Verification Script"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

echo "1. Checking environment configuration..."
echo "----------------------------------------"

# Check for main_prod.dart
if [ -f "lib/main_prod.dart" ]; then
    print_success "main_prod.dart exists"
    
    # Check if it sets Environment.prod
    if grep -q "Environment.prod" lib/main_prod.dart; then
        print_success "main_prod.dart sets Environment.prod"
    else
        print_error "main_prod.dart does NOT set Environment.prod"
    fi
else
    print_error "main_prod.dart not found"
fi

echo ""
echo "2. Checking In-App Purchase configuration..."
echo "--------------------------------------------"

# Check for product ID in model
if grep -q "tip_100" lib/models/tip_product_model.dart; then
    print_success "Product ID 'tip_100' found in tip_product_model.dart"
else
    print_warning "Product ID 'tip_100' not explicitly found in model (may be generated dynamically)"
fi

# Check iOS configuration
if [ -f "ios/Runner/Configuration.storekit" ]; then
    print_success "Configuration.storekit exists"
    
    if grep -q "tip_100" ios/Runner/Configuration.storekit; then
        print_success "Product 'tip_100' configured in StoreKit configuration"
    else
        print_error "Product 'tip_100' NOT found in StoreKit configuration"
    fi
else
    print_warning "Configuration.storekit not found"
fi

# Check entitlements
if [ -f "ios/Runner/Runner.entitlements" ]; then
    print_success "Runner.entitlements exists"
    
    # Check if it has incorrect In-App Purchase settings
    if grep -q "com.apple.developer.in-app-payments" ios/Runner/Runner.entitlements; then
        print_error "Found 'com.apple.developer.in-app-payments' in entitlements"
        print_error "This is for Apple Pay, not In-App Purchase!"
        print_error "In-App Purchase doesn't need special entitlements"
    else
        print_success "No incorrect entitlements found"
        print_success "In-App Purchase works automatically without special entitlements"
    fi
else
    print_error "Runner.entitlements not found"
fi

echo ""
echo "3. Build commands..."
echo "--------------------"

print_success "For DEVELOPMENT: make dev"
print_success "For PRODUCTION (App Store): make build-prod-ios"

echo ""
echo "4. Pre-submission checklist..."
echo "------------------------------"

echo "□ Run 'make build-prod-ios' to build for production"
echo "□ Verify in App Store Connect:"
echo "  □ Product 'tip_100' is created"
echo "  □ Product status is 'Ready to Submit' or 'Approved'"
echo "  □ Price is set to ¥100"
echo "  □ Product is available in Japan"
echo "  □ Banking and tax information is complete"
echo "□ Test with TestFlight:"
echo "  □ Upload build to TestFlight"
echo "  □ Test with Sandbox account"
echo "  □ Verify purchase flow completes successfully"
echo "  □ Check debug logs for any errors"
echo "□ Test on iPad (as per rejection notice)"

echo ""
echo "====================================="
echo "Build verification complete!"
echo "====================================="
echo ""

# Final recommendation
echo -e "${GREEN}IMPORTANT:${NC} Always use 'make build-prod-ios' for App Store submissions!"
echo ""