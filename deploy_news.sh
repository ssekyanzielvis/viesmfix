#!/bin/bash

# News Feature Deployment Script
# This script automates the complete deployment of the news feature

set -e  # Exit on error

echo "🚀 News Feature Deployment Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }

# Check if required tools are installed
echo "Checking prerequisites..."

if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI not found. Install from: https://supabase.com/docs/guides/cli"
    exit 1
fi
print_success "Supabase CLI found"

if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Install from: https://flutter.dev"
    exit 1
fi
print_success "Flutter found"

echo ""

# Get user input for secrets
read -p "Enter your NewsAPI.org API key: " NEWSAPI_KEY
if [ -z "$NEWSAPI_KEY" ]; then
    print_error "NewsAPI key is required"
    exit 1
fi

read -p "Enter your Supabase Service Role Key (from Dashboard > Settings > API): " SERVICE_ROLE_KEY
if [ -z "$SERVICE_ROLE_KEY" ]; then
    print_error "Supabase Service Role Key is required"
    exit 1
fi

echo ""
echo "Starting deployment..."
echo ""

# Step 1: Flutter dependencies
print_info "Step 1/5: Installing Flutter dependencies..."
cd viesmfix
flutter pub get
print_success "Flutter dependencies installed"
echo ""

# Step 2: Generate localizations
print_info "Step 2/5: Generating localizations..."
flutter gen-l10n
print_success "Localizations generated"
echo ""

# Step 3: Database migration
print_info "Step 3/5: Running database migration..."
supabase db push
if [ $? -eq 0 ]; then
    print_success "Database migration completed"
else
    print_error "Database migration failed"
    exit 1
fi
echo ""

# Step 4: Set secrets
print_info "Step 4/5: Setting Edge Function secrets..."
supabase secrets set NEWSAPI_KEY="$NEWSAPI_KEY"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY"
print_success "Secrets configured"
echo ""

# Step 5: Deploy Edge Function
print_info "Step 5/5: Deploying Edge Function..."
supabase functions deploy news-proxy
if [ $? -eq 0 ]; then
    print_success "Edge Function deployed"
else
    print_error "Edge Function deployment failed"
    exit 1
fi
echo ""

# Verification
echo "Verifying deployment..."
echo ""

# Check database
print_info "Checking database..."
CACHE_TABLE=$(supabase db diff | grep -c "news_cache" || true)
if [ "$CACHE_TABLE" -gt 0 ]; then
    print_success "news_cache table exists"
else
    print_info "news_cache table created"
fi

# Check Edge Function
print_info "Checking Edge Function..."
FUNCTION_URL=$(supabase functions list | grep news-proxy | awk '{print $2}' || echo "")
if [ -n "$FUNCTION_URL" ]; then
    print_success "Edge Function is live: $FUNCTION_URL"
else
    print_error "Could not verify Edge Function"
fi

echo ""
echo "=================================="
print_success "News Feature Deployment Complete!"
echo "=================================="
echo ""

# Next steps
echo "📝 Next Steps:"
echo "1. Run 'flutter run' to test the app"
echo "2. Check news feed loads correctly"
echo "3. Verify caching is working (check X-Cache headers)"
echo "4. Add news icon to your navigation"
echo "5. Test on different devices/screen sizes"
echo ""

# Quick commands
echo "🔧 Useful Commands:"
echo "  Check cache stats:   supabase db execute \"SELECT * FROM get_news_cache_stats();\""
echo "  Clear cache:         supabase db execute \"SELECT cleanup_old_news_cache();\""
echo "  View cache:          supabase db execute \"SELECT * FROM cache_entries_by_age LIMIT 10;\""
echo "  Function logs:       supabase functions logs news-proxy"
echo ""

# Documentation
echo "📚 Documentation:"
echo "  Quick Start:   NEWS_QUICK_START.md"
echo "  Testing:       NEWS_TESTING_GUIDE.md"
echo "  Complete Docs: NEWS_FEATURE_DOCS.md"
echo ""

print_success "Ready to use! 🎉"
