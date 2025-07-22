# Configuration loader for Windows Theme Switcher
# This function reads the theme-config.json file and returns the apps-only devices list

function Get-ThemeConfig {
    $scriptDir = $PSScriptRoot
    $configFile = Join-Path $scriptDir "theme-config.json"
    
    if (Test-Path $configFile) {
        try {
            $content = Get-Content $configFile -Raw -ErrorAction Stop
            $config = $content | ConvertFrom-Json -ErrorAction Stop
            if ($config.appsOnlyDevices) {
                return $config.appsOnlyDevices
            } else {
                return @()
            }
        } catch {
            Write-Warning "Could not read theme config file ($($_.Exception.Message)). Using default settings."
            return @()
        }
    } else {
        # Config file doesn't exist - this is normal on first run
        return @()
    }
}
