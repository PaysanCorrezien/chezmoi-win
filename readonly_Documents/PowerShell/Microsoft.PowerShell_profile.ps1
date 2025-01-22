## Configuration spécifique pour Psfzf
Import-Module PSReadLine
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
  Write-Host "Installing PSFzf on first init of this profile"
  Install-Module -Name PSFzf -Force
}
Import-Module PSFzf
Import-module Microsoft.PowerShell.Management
Import-Module Microsoft.PowerShell.Utility

# replace with good Ripgrep
function grep
{Invoke-PsFzfRipgrep -SearchString @args

}

## alias pour l'equivalent de ls -al linux
function ll
{ Get-ChildItem -Force @args 
}


$ENV:FZF_DEFAULT_OPTS=@"
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
"@

$env:FZF_DEFAULT_OPTS+=" --height 60%"
# Configure CTRL+T options
$env:FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
$env:FZF_CTRL_T_OPTS=@"
  --preview 'bat -n --color=always {}'
"@

# Configure default command
$env:FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

#BUG: copy dont work for now
# Configure CTRL+R options
$env:FZF_CTRL_R_OPTS=@"
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | Set-Clipboard)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
"@

#BUG: GH cli completions
# Dont work properly
# $profileDir = Split-Path -Parent $PROFILE
# . (Join-Path $profileDir 'completions/gh-cli.ps1')
# Neovim
# $configPath = "\\wsl.localhost\Debian\home\dylan\.config\nvim\init.lua"
set-alias -name n -value nvim
set-alias -name lg -value lazygit

# function ai {
#     sgpt --repl temp --shell $args
# }

# function s {
#   gsudo --copyNS $args
# # }
# function ss {
# gsudo status
# }
# 
# $env:EDITOR = "$env:USERPROFILE\.local\bin\lvim.ps1"
# 
# if (Test-Path -Path "$env:USERPROFILE\Documents\Projet\Work\Projet\WSLExplorer\OpenFileProperty.ps1")
# {
#   Import-Module "$env:USERPROFILE\Documents\Projet\Work\Projet\WSLExplorer\OpenFileProperty.ps1"
# }
# # Key
# if (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\.secret.ps1")
# {
#   Import-Module "$env:USERPROFILE\Documents\PowerShell\.secret.ps1"
# }
#Bindings 
if ($PSVersionTable.Platform -eq "Unix") {
    $bindingsPath = "/home/dylan/.local/share/chezmoi/dot_windows/powershellcore/bindings.ps1"
    $psreadlinebindingsPath = "/home/dylan/.local/share/chezmoi/dot_windows/powershellcore/psreadlinebindings.ps1"
} else {
    $bindingsPath = "$env:USERPROFILE\Documents\PowerShell\Bindings.ps1"
    $psreadlinebindingsPath = "$env:USERPROFILE\Documents\PowerShell/psreadlinebindings.ps1"
}

if (Test-Path -Path $bindingsPath) {
    Import-Module $bindingsPath
}

if (Test-Path -Path $psreadlinebindingsPath) {
    Import-Module $psreadlinebindingsPath
}
function which($name)
{
  Get-Command $name | Select-Object -ExpandProperty Definition
}
function Get-PubIP
{
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
# Compute file hashes - useful for checking successful downloads 
function md5
{ Get-FileHash -Algorithm MD5 $args 
}
function sha1
{ Get-FileHash -Algorithm SHA1 $args 
}
function sha256
{ Get-FileHash -Algorithm SHA256 $args 
}
# Find out if the current user identity is elevated (has admin rights)
# $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
# $principal = New-Object Security.Principal.WindowsPrincipal $identity
# $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Invoke-LsDeluxe {
    lsd @args
}

Set-Alias -Name ls -Value Invoke-LsDeluxe -Option AllScope

function y
{
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -Path $cwd
  }
  Remove-Item -Path $tmp
}

# NOTE: The function executes the 'ls -alt' command when called.
# 'ls -alt' lists all files and directories in the current directory,
# sorted by modification time, with the most recently modified items first.
function Reload-Powershell
{
  # Blacklist of module names that should not be removed
  $moduleBlacklist = @(
    'Microsoft.PowerShell.Commands.Management',
    'Microsoft.PowerShell.Commands.Utility',
    'Microsoft.PowerShell.Management',
    'Microsoft.PowerShell.PSReadLine2',
    'Microsoft.PowerShell.Security',
    'Microsoft.PowerShell.Utility',
    'PSReadLine'
  )
    
  # Get a list of all currently loaded modules along with their paths
  $currentModules = Get-Module -All | Select-Object Name, Path

  # Remove all currently loaded modules except those on the blacklist
  $currentModules | ForEach-Object { 
    if ($moduleBlacklist -notcontains $_.Name)
    {
      Write-Host "Removing module $($_.Name)"
      Remove-Module -Name $_.Name 
    } else
    {
      Write-Host "Skipping removal of blacklisted module $($_.Name)"
    }
  }

  # Re-import all modules using their full paths
  $currentModules | ForEach-Object { 
    if ($moduleBlacklist -notcontains $_.Name)
    {
      if ($_.Path)
      {
        Write-Host "Importing module $($_.Name) from $($_.Path)"
        Import-Module -Name $_.Path 
      } else
      {
        Write-Host "Unable to find path for module $($_.Name), attempting to import by name"
        Import-Module -Name $_.Name 
      }
    } else
    {
      Write-Host "Skipping re-import of blacklisted module $($_.Name)"
    }
  }

  # Get a list of all profiles
  $profiles = @(
    $profile.AllUsersAllHosts,
    $profile.AllUsersCurrentHost,
    $profile.CurrentUserAllHosts,
    $profile.CurrentUserCurrentHost
  )

  # Dot-source each profile if it exists
  foreach ($profilePath in $profiles)
  {
    if (Test-Path -Path $profilePath)
    {
      Write-Host "Reloading profile $profilePath"
      . $profilePath
    }
  }
}
$env:HOME = $env:USERPROFILE

# Initialize Starship
# Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# NOTE: work for osc7 only
# function Invoke-Starship-PreCommand {
#     $current_location = Get-Location
#     if ($current_location.Provider.Name -eq "FileSystem") {
#         $ansi_escape = [char]27
#         $provider_path = $current_location.ProviderPath -replace "\\", "/"
#         $prompt = "$ansi_escape]7;file:///$provider_path$ansi_escape\"
#         Write-Host -NoNewline $prompt
#     }
# }
#
# Invoke-Expression (&starship init powershell)
#
# NOTE: work for osc 133, but only that no osc7 / startship
# $Global:__LastHistoryId = -1
# $Global:__ExecutingCommand = 0
#
# function Global:__Terminal-Get-LastExitCode {
#     if ($? -eq $True) {
#         return 0
#     }
#     if ("$LastExitCode" -ne "") { return $LastExitCode }
#     return -1
# }
#
# # Create a function to handle line input
# function OnInputAccepted {
#     if ($Global:__ExecutingCommand -eq 0) {
#         # End of line input
#         Write-Host -NoNewline "`e]133;I`a"
#         # Start of command output
#         Write-Host -NoNewline "`e]133;C`a"
#         $Global:__ExecutingCommand = 1
#     }
# }
#
# # Register the input handler
# Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
#     OnInputAccepted
#     [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }
#
# # Handle command execution
# $ExecutionContext.InvokeCommand.PreCommandLookupAction = {
#     param([string]$commandName)
#     # We already marked output start in OnInputAccepted
# }
#
# function prompt {
#     $out = ""
#     $LastHistoryEntry = $(Get-History -Count 1)
#     
#     # Mark end of previous command if we were executing one
#     if ($Global:__ExecutingCommand -eq 1 -and $Global:__LastHistoryId -ne -1) {
#         # Command completed, mark its end
#         $out += "`e]133;D;aid=$PID`a"
#     }
#     
#     # Start new command sequence
#     $out += "`e]133;A;cl=m;aid=$PID`a"
#     
#     # Mark prompt content
#     $out += "`e]133;P;k=i`a"
#     
#     # Actual prompt content
#     $out += "PS > "
#     
#     # End prompt and start user input area
#     $out += "`e]133;B`a"
#     
#     # Update state tracking
#     $Global:__LastHistoryId = $LastHistoryEntry.Id
#     $Global:__ExecutingCommand = 0
#     
#     return $out
# }
# NOTE: startship, osc 7 + 133 version
#
# Global state tracking for OSC 133
# First load starship's native prompt function
Invoke-Expression (&starship init powershell)

# Store original prompt function that starship created
$original_prompt = $function:prompt

# Global state tracking for OSC 133
$Global:__LastHistoryId = -1
$Global:__ExecutingCommand = 0

function Global:__Terminal-Get-LastExitCode {
    if ($? -eq $True) {
        return 0
    }
    if ("$LastExitCode" -ne "") { return $LastExitCode }
    return -1
}

# OSC 7 directory tracking - this will run before the prompt
function Invoke-Starship-PreCommand {
    $current_location = Get-Location
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file:///$provider_path$ansi_escape\"
        Write-Host -NoNewline $prompt
    }
}

# Line input handling for OSC 133
function OnInputAccepted {
    if ($Global:__ExecutingCommand -eq 0) {
        # End of line input
        Write-Host -NoNewline "`e]133;I`a"
        # Start of command output
        Write-Host -NoNewline "`e]133;C`a"
        $Global:__ExecutingCommand = 1
    }
}

# Register the input handler
Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    OnInputAccepted
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Handle command execution
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param([string]$commandName)
    # We already marked output start in OnInputAccepted
}

# Our new prompt that wraps the original starship prompt
function prompt {
    $out = ""
    $LastHistoryEntry = $(Get-History -Count 1)
    
    # Mark end of previous command if we were executing one
    if ($Global:__ExecutingCommand -eq 1 -and $Global:__LastHistoryId -ne -1) {
        $out += "`e]133;D;aid=$PID`a"
    }
    
    # Start new command sequence
    $out += "`e]133;A;cl=m;aid=$PID`a"
    
    # Mark prompt content
    $out += "`e]133;P;k=i`a"
    
    # Get the original starship prompt content
    $starship_out = & $original_prompt
    $out += $starship_out
    
    # End prompt and start user input area
    $out += "`e]133;B`a"
    
    # Update state tracking
    $Global:__LastHistoryId = $LastHistoryEntry.Id
    $Global:__ExecutingCommand = 0
    
    return $out
}
