Add-Type -AssemblyName System.Windows.Forms

# ----------- CONFIG -----------
$scriptDir = $PSScriptRoot
$lightWallpaper = Join-Path $scriptDir "_LIGHT.jpg"
$darkWallpaper  = Join-Path $scriptDir "_DARK.jpg"

# Load configuration from theme-config.json
. (Join-Path $scriptDir "config-loader.ps1")
$appsOnlyDevices = Get-ThemeConfig
# ------------------------------

$hostname = $env:COMPUTERNAME
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# Get current hour
$currentHour = [int](Get-Date).ToString("HH")

# Define function
function Set-Wallpaper($imagePath) {
    if (!(Test-Path $imagePath)) {
        Write-Error "Wallpaper not found: $imagePath"
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Resolve-Path $imagePath))

    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
  [DllImport("user32.dll", CharSet = CharSet.Unicode)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE   = 0x01
    $SPIF_SENDCHANGE      = 0x02
    $flags = $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE

    $success = [WinAPI]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $resolved, $flags)
    if ($success) {
        Write-Output "✅ Wallpaper successfully set to: $resolved"
        return $true
    } else {
        Write-Warning "❌ Wallpaper change failed via SystemParametersInfo."
        return $false
    }
}

if ($currentHour -ge 8 -and $currentHour -lt 17) {
    # Light mode
    Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value 1
    if ($appsOnlyDevices -notcontains $hostname) {
        Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value 1
    }
    Set-Wallpaper $lightWallpaper
} else {
    # Dark mode
    Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value 0
    if ($appsOnlyDevices -notcontains $hostname) {
        Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value 0
    }
    Set-Wallpaper $darkWallpaper
}

# Optional: Ask to restart Explorer
$answer = [System.Windows.Forms.MessageBox]::Show(
    "Explorer UI may look off. Restart now?",
    "Theme: Time-based",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($answer -eq [System.Windows.Forms.DialogResult]::Yes) {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}
