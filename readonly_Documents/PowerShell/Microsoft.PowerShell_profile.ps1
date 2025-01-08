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
  function Import-EnvSecrets {
      Get-Content $HOME/.config/secrets/secrets.env | ForEach-Object {
          if ($_ -match '^([^=]+)\s*=\s*"([^"]*)"$') {
              $key = $matches[1].Trim()
              $value = $matches[2]
              Set-Item "env:$key" $value
          }
      }
  }

# Add this to your PowerShell profile to load secrets at startup
  Import-EnvSecrets

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

# Initialize Starship
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
