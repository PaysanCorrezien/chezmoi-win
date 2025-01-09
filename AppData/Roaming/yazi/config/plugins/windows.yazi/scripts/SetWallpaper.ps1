param(
    [Parameter(Mandatory=$true)]
    [string]$WallpaperPath,
    [Parameter(Mandatory=$false)]
    [switch]$LoginScreen
)

Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

try {
    # Verify file exists
    if (-not (Test-Path $WallpaperPath)) {
        throw "Wallpaper file not found: $WallpaperPath"
    }

    # Get absolute path
    $absolutePath = (Resolve-Path $WallpaperPath).Path

    # Set desktop wallpaper
    $result = [Wallpaper]::SystemParametersInfo(0x0014, 0, $absolutePath, 0x01 -bor 0x02)
    if ($result -eq 0) {
        throw "SystemParametersInfo failed to set wallpaper"
    }

    # Set login screen wallpaper if requested
    if ($LoginScreen) {
        # Requires admin privileges
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "Administrator privileges required to set login screen wallpaper"
        }

        # Copy image to system location
        $destinationPath = "$env:windir\System32\oobe\info\backgrounds"
        if (-not (Test-Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path $absolutePath -Destination "$destinationPath\backgroundDefault.jpg" -Force

        # Set registry keys
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "OEMBackground" -Value 1
    }

    Write-Host "Wallpaper set successfully"
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
