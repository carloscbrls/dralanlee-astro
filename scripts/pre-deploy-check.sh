#!/bin/bash
# Pre-Deployment iOS/Safari Form Check Script
# Run this BEFORE every deployment to catch Safari issues

set -euo pipefail

echo "========================================="
echo "🔍 iOS Safari Pre-Deployment Check"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check if build exists
check_build() {
    if [ ! -d "dist" ]; then
        echo -e "${RED}❌ No dist/ folder found. Run 'npm run build' first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ dist/ folder exists${NC}"
}

# Function to check viewport meta
check_viewport() {
    local index_file="dist/index.html"
    if grep -q "user-scalable=no" "$index_file" 2>/dev/null; then
        echo -e "${RED}❌ Found user-scalable=no in viewport meta (WCAG violation)${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✅ Viewport meta allows user scaling${NC}"
    fi
}

# Function to check JotForm embed method
check_jotform_embeds() {
    local contact_file="dist/contact/index.html"
    if [ -f "$contact_file" ]; then
        # Check actual embed method (not just CSS references to iframe)
        if grep -q 'src="https://form.jotform.com/jsform/' "$contact_file"; then
            echo -e "${GREEN}✅ Contact page uses JotForm JS embed${NC}"
        elif grep -q 'src="https://form.jotform.com/' "$contact_file" | grep -v jsform; then
            echo -e "${RED}❌ Contact page may use JotForm iframe (iOS scroll issues)${NC}"
            echo -e "   ${YELLOW}💡 Fix: Use JS embed: https://form.jotform.com/jsform/FORM_ID${NC}"
            ((ERRORS++))
        fi
    fi
    
    local schedule_file="dist/schedule-appointment/index.html"
    if [ -f "$schedule_file" ]; then
        if grep -q 'src="https://form.jotform.com/jsform/' "$schedule_file"; then
            echo -e "${GREEN}✅ Schedule page uses JotForm JS embed${NC}"
        elif grep -q 'src="https://form.jotform.com/' "$schedule_file" | grep -v jsform; then
            echo -e "${RED}❌ Schedule page may use JotForm iframe (iOS scroll issues)${NC}"
            ((ERRORS++))
        fi
    fi
    
    # Also check source files for iframe-based embeds
    local src_contact="src/pages/contact.astro"
    if [ -f "$src_contact" ]; then
        if grep -q 'src="https://form.jotform.com/' "$src_contact" | grep -v jsform | grep -v iframe; then
            echo -e "${YELLOW}⚠️  Source contact.astro may have non-JS JotForm embed${NC}"
        fi
    fi
}

# Function to check HTTPS for form URLs
check_https() {
    if grep -r "http://form\.jotform\.com\|http://www\.jotform\.com" dist/ 2>/dev/null | grep -v "https://" | head -3; then
        echo -e "${RED}❌ Found HTTP JotForm URLs (should be HTTPS)${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✅ All JotForm URLs use HTTPS${NC}"
    fi
}

# Function to check touch target sizes in CSS
check_touch_targets() {
    local css_file=$(find dist/_astro -name "*.css" | head -1)
    if [ -n "$css_file" ]; then
        # Check for small padding that might indicate small touch targets
        if grep -o "padding:[ ]*[0-9]px" "$css_file" | head -5; then
            echo -e "${YELLOW}⚠️  Found small padding values in CSS (verify touch targets ≥ 44px)${NC}"
            ((WARNINGS++))
        fi
    fi
}

# Function to check font sizes
check_font_sizes() {
    local css_file=$(find dist/_astro -name "*.css" | head -1)
    if [ -n "$css_file" ]; then
        if grep -o "font-size:[ ]*1[0-5]px" "$css_file" | head -3; then
            echo -e "${YELLOW}⚠️  Found font sizes < 16px (may cause iOS zoom on input focus)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✅ No small font sizes found${NC}"
        fi
    fi
}

# Function to check for iOS-specific CSS
check_ios_css() {
    local css_file=$(find dist/_astro -name "*.css" | head -1)
    if [ -n "$css_file" ]; then
        if grep -q "-webkit-appearance" "$css_file"; then
            echo -e "${GREEN}✅ Found -webkit-appearance CSS (good for iOS form styling)${NC}"
        else
            echo -e "${YELLOW}⚠️  No -webkit-appearance found (may have iOS form styling issues)${NC}"
            ((WARNINGS++))
        fi
    fi
}

# Run checks
echo "Running pre-deployment checks..."
echo ""

check_build
check_viewport
check_jotform_embeds
check_https
check_touch_targets
check_font_sizes
check_ios_css

echo ""
echo "========================================="
echo "📊 Results Summary"
echo "========================================="

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo -e "${YELLOW}⚠️  Warnings: ${WARNINGS}${NC}"
    echo ""
    echo "Ready to deploy. Run:"
    echo "  npx netlify deploy --prod --dir=dist"
    exit 0
else
    echo -e "${RED}❌ Errors found: ${ERRORS}${NC}"
    echo -e "${YELLOW}⚠️  Warnings: ${WARNINGS}${NC}"
    echo ""
    echo "Fix errors before deploying to prevent Safari/iPhone issues."
    exit 1
fi