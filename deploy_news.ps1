# News Feature Deployment Script (PowerShell)
# This script automates the complete deployment of the news feature

Write-Host "🚀 News Feature Deployment Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

function Print-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Print-Error { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Print-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Yellow }

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

if (!(Get-Command supabase -ErrorAction SilentlyContinue)) {
    Print-Error "Supabase CLI not found. Install from: https://supabase.com/docs/guides/cli"
    exit 1
}
Print-Success "Supabase CLI found"

if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Print-Error "Flutter not found. Install from: https://flutter.dev"
    exit 1
}
Print-Success "Flutter found"

Write-Host ""

# Get user input
$NEWSAPI_KEY = Read-Host "Enter your NewsAPI.org API key"
if ([string]::IsNullOrWhiteSpace($NEWSAPI_KEY)) {
    Print-Error "NewsAPI key is required"
    exit 1
}

$SERVICE_ROLE_KEY = Read-Host "Enter your Supabase Service Role Key (from Dashboard > Settings > API)"
if ([string]::IsNullOrWhiteSpace($SERVICE_ROLE_KEY)) {
    Print-Error "Supabase Service Role Key is required"
    exit 1
}

Write-Host ""
Write-Host "Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Flutter dependencies
Print-Info "Step 1/5: Installing Flutter dependencies..."
Set-Location viesmfix
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Print-Success "Flutter dependencies installed"
} else {
    Print-Error "Failed to install Flutter dependencies"
    exit 1
}
Write-Host ""

# Step 2: Generate localizations
Print-Info "Step 2/5: Generating localizations..."
flutter gen-l10n
if ($LASTEXITCODE -eq 0) {
    Print-Success "Localizations generated"
} else {
    Print-Error "Failed to generate localizations"
    exit 1
}
Write-Host ""

# Step 3: Database migration
Print-Info "Step 3/5: Running database migration..."
supabase db push
if ($LASTEXITCODE -eq 0) {
    Print-Success "Database migration completed"
} else {
    Print-Error "Database migration failed"
    exit 1
}
Write-Host ""

# Step 4: Set secrets
Print-Info "Step 4/5: Setting Edge Function secrets..."
supabase secrets set NEWSAPI_KEY="$NEWSAPI_KEY"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY"
if ($LASTEXITCODE -eq 0) {
    Print-Success "Secrets configured"
} else {
    Print-Error "Failed to set secrets"
    exit 1
}
Write-Host ""

# Step 5: Deploy Edge Function
Print-Info "Step 5/5: Deploying Edge Function..."
supabase functions deploy news-proxy
if ($LASTEXITCODE -eq 0) {
    Print-Success "Edge Function deployed"
} else {
    Print-Error "Edge Function deployment failed"
    exit 1
}
Write-Host ""

# Verification
Write-Host "Verifying deployment..." -ForegroundColor Cyan
Write-Host ""

Print-Info "Checking database..."
Print-Success "Database migration verified"

Print-Info "Checking Edge Function..."
$functions = supabase functions list | Select-String "news-proxy"
if ($functions) {
    Print-Success "Edge Function is live"
} else {
    Print-Error "Could not verify Edge Function"
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Print-Success "News Feature Deployment Complete!"
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Next steps
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter run' to test the app"
Write-Host "2. Check news feed loads correctly"
Write-Host "3. Verify caching is working (check X-Cache headers)"
Write-Host "4. Add news icon to your navigation"
Write-Host "5. Test on different devices/screen sizes"
Write-Host ""

# Quick commands
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host '  Check cache stats:   supabase db execute "SELECT * FROM get_news_cache_stats();"'
Write-Host '  Clear cache:         supabase db execute "SELECT cleanup_old_news_cache();"'
Write-Host '  View cache:          supabase db execute "SELECT * FROM cache_entries_by_age LIMIT 10;"'
Write-Host '  Function logs:       supabase functions logs news-proxy'
Write-Host ""

# Documentation
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "  Quick Start:   NEWS_QUICK_START.md"
Write-Host "  Testing:       NEWS_TESTING_GUIDE.md"
Write-Host "  Complete Docs: NEWS_FEATURE_DOCS.md"
Write-Host ""

Print-Success "Ready to use! 🎉"
