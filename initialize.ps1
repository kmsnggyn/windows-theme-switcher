Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

# Windows Theme Switcher - Initialization Script
Write-Host "=== Windows Theme Switcher Setup ===" -ForegroundColor Cyan
Write-Host ""

# Get current computer name
$currentComputerName = $env:COMPUTERNAME
Write-Host "Current computer name detected: " -NoNewline
Write-Host $currentComputerName -ForegroundColor Yellow

# Ask user about computer name configuration
Write-Host ""
Write-Host "Configuration Options:" -ForegroundColor Green
Write-Host "1. Use current computer name ($currentComputerName)"
Write-Host "2. Enter a different computer name"
Write-Host "3. Configure for multiple computers"
Write-Host ""

do {
    $choice = Read-Host "Choose an option (1-3)"
} while ($choice -notin @('1', '2', '3'))

$deviceNames = @()

switch ($choice) {
    '1' {
        $deviceNames = @($currentComputerName)
        Write-Host "Using current computer: $currentComputerName" -ForegroundColor Green
    }
    '2' {
        do {
            $customName = Read-Host "Enter the computer name to configure"
        } while ([string]::IsNullOrWhiteSpace($customName))
        $deviceNames = @($customName.Trim())
        Write-Host "Using custom computer name: $($deviceNames[0])" -ForegroundColor Green
    }
    '3' {
        Write-Host "Enter computer names (press Enter on empty line to finish):"
        do {
            $name = Read-Host "Computer name"
            if (![string]::IsNullOrWhiteSpace($name)) {
                $deviceNames += $name.Trim()
                Write-Host "Added: $($name.Trim())" -ForegroundColor Gray
            }
        } while (![string]::IsNullOrWhiteSpace($name))
        
        if ($deviceNames.Count -eq 0) {
            $deviceNames = @($currentComputerName)
            Write-Host "No names entered, using current computer: $currentComputerName" -ForegroundColor Yellow
        }
    }
}

# Ask about theme scope
Write-Host ""
Write-Host "Theme Scope Configuration:" -ForegroundColor Green
Write-Host "- Apps Only: Changes theme for applications (File Explorer, etc.)"
Write-Host "- Full Theme: Changes both applications AND system (taskbar, start menu, etc.)"
Write-Host ""
Write-Host "Note: Full theme changes the taskbar and system UI, which some users prefer to keep consistent."
Write-Host ""

do {
    $themeScope = Read-Host "Apply full theme changes to configured devices? (y/n)"
} while ($themeScope -notin @('y', 'Y', 'n', 'N', 'yes', 'Yes', 'no', 'No'))

$useFullTheme = $themeScope -match '^(y|Y|yes|Yes)$'

if ($useFullTheme) {
    Write-Host "Full theme (apps + system) will be applied to: $($deviceNames -join ', ')" -ForegroundColor Green
} else {
    Write-Host "Apps-only theme will be applied. System theme will remain unchanged." -ForegroundColor Yellow
}

# Create the device array string for PowerShell scripts
$deviceArrayString = '@("' + ($deviceNames -join '", "') + '")'

# Ask about wallpaper setup
Write-Host ""
Write-Host "Wallpaper Configuration:" -ForegroundColor Green
$scriptDir = $PSScriptRoot

$darkWallpaperExists = Test-Path (Join-Path $scriptDir "_DARK.jpg")
$lightWallpaperExists = Test-Path (Join-Path $scriptDir "_LIGHT.jpg")

Write-Host "Dark wallpaper (_DARK.jpg): " -NoNewline
if ($darkWallpaperExists) {
    Write-Host "✅ Found" -ForegroundColor Green
} else {
    Write-Host "❌ Missing" -ForegroundColor Red
}

Write-Host "Light wallpaper (_LIGHT.jpg): " -NoNewline
if ($lightWallpaperExists) {
    Write-Host "✅ Found" -ForegroundColor Green
} else {
    Write-Host "❌ Missing" -ForegroundColor Red
}

if (!$darkWallpaperExists -or !$lightWallpaperExists) {
    Write-Host ""
    Write-Host "Missing wallpapers detected!" -ForegroundColor Yellow
    Write-Host "Please add your wallpaper files to this folder:"
    Write-Host "- _DARK.jpg  (for dark theme)"
    Write-Host "- _LIGHT.jpg (for light theme)"
    Write-Host ""
    
    $continueSetup = Read-Host "Continue with setup anyway? (y/n)"
    if ($continueSetup -notmatch '^(y|Y|yes|Yes)$') {
        Write-Host "Setup cancelled. Please add wallpapers and run this script again." -ForegroundColor Yellow
        exit
    }
}

# Update scripts
Write-Host ""
Write-Host "Updating PowerShell scripts..." -ForegroundColor Cyan

$scriptsToUpdate = @(
    'dark-mode.ps1',
    'light-mode.ps1', 
    'toggle-theme.ps1',
    'set-theme-by-time.ps1'
)

$updatedCount = 0

foreach ($scriptFile in $scriptsToUpdate) {
    $scriptPath = Join-Path $scriptDir $scriptFile
    
    if (Test-Path $scriptPath) {
        try {
            $content = Get-Content $scriptPath -Raw
            
            # Update the fullThemeDevices array
            if ($useFullTheme) {
                $newContent = $content -replace '\$fullThemeDevices\s*=\s*@\([^)]*\)', "`$fullThemeDevices = $deviceArrayString"
            } else {
                # If not using full theme, set to empty array so system theme won't be changed
                $newContent = $content -replace '\$fullThemeDevices\s*=\s*@\([^)]*\)', '$fullThemeDevices = @()'
            }
            
            Set-Content $scriptPath -Value $newContent -NoNewline
            Write-Host "✅ Updated: $scriptFile" -ForegroundColor Green
            $updatedCount++
        }
        catch {
            Write-Host "❌ Failed to update: $scriptFile - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️  Not found: $scriptFile" -ForegroundColor Yellow
    }
}

# Summary
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "Updated $updatedCount PowerShell scripts" -ForegroundColor Green
Write-Host ""

if ($useFullTheme) {
    Write-Host "Configuration:" -ForegroundColor White
    Write-Host "- Device(s): $($deviceNames -join ', ')" -ForegroundColor Gray
    Write-Host "- Theme scope: Full (apps + system)" -ForegroundColor Gray
} else {
    Write-Host "Configuration:" -ForegroundColor White
    Write-Host "- Device(s): $($deviceNames -join ', ')" -ForegroundColor Gray
    Write-Host "- Theme scope: Apps only" -ForegroundColor Gray
}

Write-Host ""
Write-Host "You can now use the theme scripts:" -ForegroundColor Green
Write-Host "- .\dark-mode.ps1     - Switch to dark theme"
Write-Host "- .\light-mode.ps1    - Switch to light theme"
Write-Host "- .\toggle-theme.ps1  - Toggle between themes"
Write-Host "- .\set-theme-by-time.ps1 - Set theme based on time"
Write-Host ""
Write-Host "For silent execution, use the .vbs files:"
Write-Host "- toggle-theme.vbs"
Write-Host "- set-theme-by-time.vbs"
Write-Host ""

# Offer to test
$testNow = Read-Host "Would you like to test the toggle script now? (y/n)"
if ($testNow -match '^(y|Y|yes|Yes)$') {
    Write-Host ""
    Write-Host "Running toggle-theme.ps1..." -ForegroundColor Cyan
    & (Join-Path $scriptDir "toggle-theme.ps1")
}

Write-Host ""
Write-Host "Setup completed successfully! 🎉" -ForegroundColor Green
