Add-Type -AssemblyName System.Windows.Forms

# Error handling - prevent window from closing on errors
$ErrorActionPreference = "Continue"
trap {
    Write-Host "❌ Error occurred: $_" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to continue..."
    continue
}

Write-Host "🎨 Windows Theme Switcher - Configuration Manager" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Get current computer name
$currentComputer = $env:COMPUTERNAME
Write-Host "📊 Current computer: $currentComputer" -ForegroundColor Green
Write-Host ""

# Load existing configuration from config file
$scriptDir = $PSScriptRoot
$configFile = Join-Path $scriptDir "theme-config.json"
$currentAppsOnlyDevices = @()

if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($config.appsOnlyDevices) {
            $currentAppsOnlyDevices = $config.appsOnlyDevices | Where-Object { $_ -ne "" -and $_ -ne "YOUR_COMPUTER_NAME" }
        }
    } catch {
        Write-Warning "⚠️  Could not read config file. Using default settings."
        $currentAppsOnlyDevices = @()
    }
} else {
    # Create default config file
    $defaultConfig = @{
        appsOnlyDevices = @()
        version = "1.0"
        lastModified = (Get-Date -Format "yyyy-MM-dd")
    }
    $defaultConfig | ConvertTo-Json -Depth 3 | Set-Content $configFile
}

# Show current configuration
Write-Host "📋 Current Device Configuration:" -ForegroundColor Yellow
if ($currentAppsOnlyDevices.Count -eq 0) {
    Write-Host "   • No devices configured for Apps-Only mode" -ForegroundColor Gray
    Write-Host "   • All devices will use Full Theme mode (apps + system UI)" -ForegroundColor Gray
} else {
    Write-Host "   Apps-Only devices:" -ForegroundColor Cyan
    foreach ($device in $currentAppsOnlyDevices) {
        $status = if ($device -eq $currentComputer) { " (THIS COMPUTER)" } else { "" }
        Write-Host "   • $device$status" -ForegroundColor White
    }
    Write-Host "   • All other devices use Full Theme mode" -ForegroundColor Gray
}
Write-Host ""

# Configuration menu
Write-Host "⚙️  Configuration Options:" -ForegroundColor Yellow
Write-Host "  [1] Configure current device (${currentComputer})"
Write-Host "  [2] Add/Remove Apps-Only devices"
Write-Host "  [3] View all device settings"
Write-Host "  [4] Skip configuration"
Write-Host ""

do {
    $choice = Read-Host "Choose option (1-4) [Default: 1]"
    if ($choice -eq "") { $choice = "1" }
} while ($choice -notin @("1", "2", "3", "4"))

$appsOnlyDevices = $currentAppsOnlyDevices

switch ($choice) {
    "1" {
        # Configure current device
        Write-Host ""
        Write-Host "🔧 Configuring ${currentComputer}:" -ForegroundColor Cyan
        Write-Host "  [1] Full Theme - Changes apps + taskbar/system UI"
        Write-Host "  [2] Apps Only - Changes only File Explorer and apps"
        Write-Host ""
        
        $currentMode = if ($appsOnlyDevices -contains $currentComputer) { "2" } else { "1" }
        Write-Host "Current mode: $(if ($currentMode -eq '2') { 'Apps Only' } else { 'Full Theme' })" -ForegroundColor Gray
        
        do {
            $deviceChoice = Read-Host "Choose mode for this device (1 or 2) [Default: $currentMode]"
            if ($deviceChoice -eq "") { $deviceChoice = $currentMode }
        } while ($deviceChoice -notin @("1", "2"))
        
        if ($deviceChoice -eq "2") {
            if ($appsOnlyDevices -notcontains $currentComputer) {
                $appsOnlyDevices += $currentComputer
            }
            Write-Host "✅ ${currentComputer} configured for Apps-Only theme changes" -ForegroundColor Green
        } else {
            $appsOnlyDevices = $appsOnlyDevices | Where-Object { $_ -ne $currentComputer }
            Write-Host "✅ ${currentComputer} configured for Full theme changes" -ForegroundColor Green
        }
    }
    "2" {
        # Manage device list
        Write-Host ""
        Write-Host "📝 Device Management:" -ForegroundColor Cyan
        Write-Host "  [a] Add device to Apps-Only list"
        Write-Host "  [r] Remove device from Apps-Only list"
        Write-Host "  [s] Skip device management"
        Write-Host ""
        
        do {
            $mgmtChoice = Read-Host "Choose action (a/r/s) [Default: s]"
            if ($mgmtChoice -eq "") { $mgmtChoice = "s" }
        } while ($mgmtChoice -notin @("a", "r", "s"))
        
        if ($mgmtChoice -eq "a") {
            $newDevice = Read-Host "Enter device name to add to Apps-Only list"
            if ($newDevice -and $newDevice.Trim() -ne "") {
                $newDevice = $newDevice.Trim()
                if ($appsOnlyDevices -notcontains $newDevice) {
                    $appsOnlyDevices += $newDevice
                    Write-Host "✅ Added $newDevice to Apps-Only list" -ForegroundColor Green
                } else {
                    Write-Host "⚠️  $newDevice is already in Apps-Only list" -ForegroundColor Yellow
                }
            }
        } elseif ($mgmtChoice -eq "r") {
            if ($appsOnlyDevices.Count -eq 0) {
                Write-Host "ℹ️  No devices in Apps-Only list to remove" -ForegroundColor Gray
            } else {
                Write-Host "Current Apps-Only devices:"
                for ($i = 0; $i -lt $appsOnlyDevices.Count; $i++) {
                    Write-Host "  [$($i+1)] $($appsOnlyDevices[$i])"
                }
                $removeChoice = Read-Host "Enter number to remove (or 0 to cancel)"
                $removeIndex = [int]$removeChoice - 1
                if ($removeIndex -ge 0 -and $removeIndex -lt $appsOnlyDevices.Count) {
                    $removedDevice = $appsOnlyDevices[$removeIndex]
                    $appsOnlyDevices = $appsOnlyDevices | Where-Object { $_ -ne $removedDevice }
                    Write-Host "✅ Removed $removedDevice from Apps-Only list" -ForegroundColor Green
                }
            }
        }
    }
    "3" {
        # View settings only
        Write-Host ""
        Write-Host "📊 All Device Settings:" -ForegroundColor Cyan
        if ($appsOnlyDevices.Count -eq 0) {
            Write-Host "   • All devices use Full Theme mode (apps + system UI)" -ForegroundColor White
        } else {
            Write-Host "   Apps-Only devices (File Explorer + apps only):" -ForegroundColor Yellow
            foreach ($device in $appsOnlyDevices) {
                $status = if ($device -eq $currentComputer) { " ← THIS COMPUTER" } else { "" }
                Write-Host "   • $device$status" -ForegroundColor White
            }
            Write-Host ""
            Write-Host "   Full Theme devices (apps + system UI):" -ForegroundColor Yellow
            Write-Host "   • All other devices not listed above" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "ℹ️  No changes made to configuration" -ForegroundColor Gray
    }
    "4" {
        Write-Host "⏭️  Skipping configuration..." -ForegroundColor Gray
    }
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

# Save configuration to config file
if ($choice -ne "3" -and $choice -ne "4") {
    Write-Host ""
    Write-Host "� Saving configuration..." -ForegroundColor Yellow

    try {
        $config = @{
            appsOnlyDevices = @($appsOnlyDevices)
            version = "1.0"
            lastModified = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content $configFile
        Write-Host "  ✅ Configuration saved to: theme-config.json" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🎉 Configuration applied successfully!" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Failed to save configuration: $_" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "ℹ️  No configuration changes applied" -ForegroundColor Gray
}
Write-Host ""
Write-Host "🚀 Available theme scripts:" -ForegroundColor Cyan
Write-Host "   .\toggle-theme.ps1     - Toggle between themes"
Write-Host "   .\dark-mode.ps1        - Switch to dark mode"
Write-Host "   .\light-mode.ps1       - Switch to light mode"
Write-Host "   .\set-theme-by-time.ps1 - Auto-switch by time"
Write-Host "   .\configure.ps1        - Run this configuration again"
Write-Host ""

if (-not ($darkExists -and $lightExists)) {
    Write-Host "❗ Don't forget to add your wallpaper files!" -ForegroundColor Yellow
    Write-Host ""
}

# Ask to run a test
if ($choice -ne "3" -and $choice -ne "4") {
    $test = Read-Host "Would you like to test theme switching now? (y/n) [Default: n]"
    if ($test -eq "y" -or $test -eq "Y") {
        Write-Host ""
        Write-Host "🧪 Running toggle test..." -ForegroundColor Cyan
        & "$scriptDir\toggle-theme.ps1"
    }
} else {
    # For view-only or skip options, pause before closing
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

# Final safety pause to prevent window from closing unexpectedly
Write-Host ""
Write-Host "🎉 Configuration complete! You can now close this window." -ForegroundColor Green
