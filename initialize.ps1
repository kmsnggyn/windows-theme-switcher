Add-Type -AssemblyName System.Windows.Forms

Write-Host "🎨 Windows Theme Switcher - Initial Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get current computer name
$currentComputer = $env:COMPUTERNAME
Write-Host "📊 Detected computer name: $currentComputer" -ForegroundColor Green
Write-Host ""

# Ask about theme scope preference
Write-Host "⚙️  Theme Change Scope:" -ForegroundColor Yellow
Write-Host "  [1] Full Theme (Default) - Changes apps + taskbar/system UI"
Write-Host "  [2] Apps Only - Changes only File Explorer and apps"
Write-Host ""

do {
    $choice = Read-Host "Choose scope (1 or 2) [Default: 1]"
    if ($choice -eq "") { $choice = "1" }
} while ($choice -notin @("1", "2"))

$appsOnlyDevices = @()
if ($choice -eq "2") {
    $appsOnlyDevices = @($currentComputer)
    Write-Host "✅ Configured for Apps-Only theme changes" -ForegroundColor Green
} else {
    Write-Host "✅ Configured for Full theme changes" -ForegroundColor Green
}

# Check for wallpaper files
Write-Host ""
Write-Host "🖼️  Checking wallpaper files..." -ForegroundColor Yellow

$scriptDir = $PSScriptRoot
$darkWallpaper = Join-Path $scriptDir "_DARK.jpg"
$lightWallpaper = Join-Path $scriptDir "_LIGHT.jpg"

$darkExists = Test-Path $darkWallpaper
$lightExists = Test-Path $lightWallpaper

if ($darkExists) {
    Write-Host "✅ Found: _DARK.jpg" -ForegroundColor Green
} else {
    Write-Host "❌ Missing: _DARK.jpg" -ForegroundColor Red
}

if ($lightExists) {
    Write-Host "✅ Found: _LIGHT.jpg" -ForegroundColor Green
} else {
    Write-Host "❌ Missing: _LIGHT.jpg" -ForegroundColor Red
}

if (-not ($darkExists -and $lightExists)) {
    Write-Host ""
    Write-Host "⚠️  Some wallpaper files are missing!" -ForegroundColor Yellow
    Write-Host "   Please add your wallpaper files to this folder:"
    Write-Host "   - _DARK.jpg  (for dark mode)"
    Write-Host "   - _LIGHT.jpg (for light mode)"
    Write-Host ""
}

# Update all PowerShell scripts
Write-Host ""
Write-Host "🔧 Updating script configurations..." -ForegroundColor Yellow

$scripts = @(
    "dark-mode.ps1",
    "light-mode.ps1", 
    "toggle-theme.ps1",
    "set-theme-by-time.ps1"
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path $scriptDir $script
    if (Test-Path $scriptPath) {
        $content = Get-Content $scriptPath -Raw
        
        # Update the appsOnlyDevices array
        if ($content -match '\$appsOnlyDevices\s*=\s*@\([^)]*\)') {
            $newLine = "`$appsOnlyDevices = @($($appsOnlyDevices | ForEach-Object { "`"$_`"" } | Join-String -Separator ', '))"
            $content = $content -replace '\$appsOnlyDevices\s*=\s*@\([^)]*\)', $newLine
        }
        
        Set-Content $scriptPath $content -NoNewline
        Write-Host "  ✅ Updated: $script" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 You can now use any of these scripts:" -ForegroundColor Cyan
Write-Host "   .\toggle-theme.ps1     - Toggle between themes"
Write-Host "   .\dark-mode.ps1        - Switch to dark mode"
Write-Host "   .\light-mode.ps1       - Switch to light mode"
Write-Host "   .\set-theme-by-time.ps1 - Auto-switch by time"
Write-Host ""

if (-not ($darkExists -and $lightExists)) {
    Write-Host "❗ Don't forget to add your wallpaper files!" -ForegroundColor Yellow
    Write-Host ""
}

# Ask to run a test
$test = Read-Host "Would you like to test theme switching now? (y/n) [Default: n]"
if ($test -eq "y" -or $test -eq "Y") {
    Write-Host ""
    Write-Host "🧪 Running toggle test..." -ForegroundColor Cyan
    & "$scriptDir\toggle-theme.ps1"
}
