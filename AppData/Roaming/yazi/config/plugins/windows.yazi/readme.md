# Windows Plugin for Yazi

A plugin that adds Windows-specific functionality to Yazi file manager.

## Requirements

- PowerShell Core (pwsh.exe) is **required** - the plugin won't work with Windows PowerShell (powershell.exe)
  - Install from: https://github.com/PowerShell/PowerShell/releases

## Features & Keybindings

Add these to your Yazi keymap configuration:

```toml
[[manager.prepend_keymap]]
desc = "Open File Details"
on = ["c", "P"]
run = "plugin windows --args='properties'"

[[manager.prepend_keymap]]
desc = "Open PowerShell Here"
on = ["g", "p"]
run = "plugin windows --args='powershell'"

[[manager.prepend_keymap]]
desc = "Open PowerShell Admin"
on = ["g", "P"]
run = "plugin windows --args='powershell_admin'"

[[manager.prepend_keymap]]
desc = "Set as Wallpapar"
on = ["m", "W"]
run = "plugin windows --args='set-wallpaper'"

[[manager.prepend_keymap]]
desc = "Open Windows Explorer"
on = ["g", "E"]
run = "plugin windows --args='open-explorer'"
```

## How it Works

The plugin uses:
- PowerShell scripts to interface with Windows
- Windows Shell API through C# for the properties dialog
- Proper process handling for admin elevation

## Notes

- The properties dialog will stay open until you close it
- PowerShell sessions open in a new window
- Admin PowerShell will trigger UAC prompt as expected
