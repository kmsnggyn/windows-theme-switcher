# Configuration loader for Windows Theme Switcher
# This function reads the theme-config.json file and returns the apps-only devices list

function Get-ThemeConfig {
    $scriptDir = $PSScriptRoot
    $configFile = Join-Path $scriptDir "theme-config.json"
    
    if (Test-Path $configFile) {
        try {
            $config = Get-Content $configFile -Raw | ConvertFrom-Json
            if ($config.appsOnlyDevices) {
                return $config.appsOnlyDevices
            }
        } catch {
            Write-Warning "Could not read theme config file. Using default settings."
        }
    }
    
    # Return default (empty array) if config file doesn't exist or can't be read
    return @()
}
