# Runs Flutter app using .env variables as dart-defines (Windows PowerShell)
# Usage: .\scripts\run-dev.ps1

$ErrorActionPreference = 'Stop'

# Workspace root (this script lives in /scripts)
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env"
$projectRoot = Join-Path $root "viesmfix\viesmfix"

if (-not (Test-Path $projectRoot)) {
  Write-Error "Project root not found at $projectRoot"
}

# Load .env (KEY=VALUE) into $env:*
if (Test-Path $envFile) {
  Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }
    if ($line.StartsWith('#')) { return }
    if ($line -notmatch '=') { return }
    $parts = $line.Split('=',2)
    $key = $parts[0].Trim()
    $val = $parts[1].Trim()
    # Strip surrounding quotes if present
    if ($val.StartsWith('"') -and $val.EndsWith('"')) { $val = $val.Substring(1, $val.Length-2) }
    if ($val.StartsWith("'") -and $val.EndsWith("'")) { $val = $val.Substring(1, $val.Length-2) }
    if ($key) {
      $env:$key = $val
    }
  }
  Write-Host ".env loaded"
} else {
  Write-Warning ".env not found at $envFile (continuing)"
}

# Validate required vars
$required = @("TMDB_API_KEY","SUPABASE_URL","SUPABASE_ANON_KEY")
$missing = @()
foreach ($k in $required) { if (-not $env:$k) { $missing += $k } }
if ($missing.Count -gt 0) {
  Write-Warning ("Missing env vars: {0}" -f ($missing -join ", "))
}

# Run Flutter with dart-defines from env
Push-Location $projectRoot
try {
  flutter run `
    --dart-define=TMDB_API_KEY=$($env:TMDB_API_KEY) `
    --dart-define=SUPABASE_URL=$($env:SUPABASE_URL) `
    --dart-define=SUPABASE_ANON_KEY=$($env:SUPABASE_ANON_KEY)
}
finally {
  Pop-Location
}
