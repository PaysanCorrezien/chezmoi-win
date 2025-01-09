param (
    [string]$path,
    [switch]$Admin
)

# Setup logging
$logFile = Join-Path $env:TEMP "yazi_pwsh_session.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Starting PowerShell session" | Out-File -FilePath $logFile -Append
"[$timestamp] Received path: $path" | Out-File -FilePath $logFile -Append
"[$timestamp] Admin mode: $Admin" | Out-File -FilePath $logFile -Append

# Determine if the path is a file or a directory
if (Test-Path -Path $path -PathType Leaf) {
    $directory = Split-Path -Path $path
    "[$timestamp] Path is a file, using parent directory: $directory" | Out-File -FilePath $logFile -Append
} elseif (Test-Path -Path $path -PathType Container) {
    $directory = $path
    "[$timestamp] Path is a directory: $directory" | Out-File -FilePath $logFile -Append
} else {
    "[$timestamp] ERROR: Path does not exist: $path" | Out-File -FilePath $logFile -Append
    Write-Error "The path does not exist: $path"
    exit 1
}

# Decide whether to start PowerShell as admin or regular user
try {
    if ($Admin) {
        "[$timestamp] Starting PowerShell as Admin in directory: $directory" | Out-File -FilePath $logFile -Append
        Start-Process pwsh.exe -ArgumentList "-NoExit", "-Command", "cd '$directory'" -Verb RunAs
    } else {
        "[$timestamp] Starting PowerShell in directory: $directory" | Out-File -FilePath $logFile -Append
        Start-Process pwsh.exe -ArgumentList "-NoExit", "-Command", "cd '$directory'"
    }
    "[$timestamp] PowerShell started successfully" | Out-File -FilePath $logFile -Append
} catch {
    "[$timestamp] ERROR: Failed to start PowerShell: $_" | Out-File -FilePath $logFile -Append
    Write-Error "Failed to start PowerShell: $_"
    exit 1
}

