# Carapace completion configuration
let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

# Load keybindings from file
source "C:\\Users\\admin\\AppData\\Roaming\\nushell\\keybindings.nu"
source "C:\\Users\\admin\\AppData\\Roaming\\nushell\\menus.nu"

# Main environment configuration
$env.config = {
    show_banner: false
    history: {
        max_size: 100_000
        sync_on_enter: false
        file_format: "sqlite"
        isolation: true
    }
    keybindings: $keybindings
    menus: $menus

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        sort: "smart"
        external: {
            enable: true
            max_results: 100
            completer: $carapace_completer
        }
        use_ls_colors: true
    }
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: true
        osc133: false # window limit
        osc633: true
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false
    use_kitty_protocol: true
    highlight_resolved_externals: true
}

# Set environment variables
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Yazi file manager integration
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

alias n = nvim
alias lg = lazygit

#load secrets from file
load-env (open ~/.config/secrets/secrets.env | from toml)
load-env {}

# External tool initializations
source "C:\\Users\\admin\\AppData\\Roaming\\nushell\\starship.nu"
source "C:\\Users\\admin\\AppData\\Roaming\\nushell\\zoxide.nu"
source "C:\\Users\\admin\\AppData\\Roaming\\nushell\\atuin.nu"

def "_aichat_nushell" [] {
    let _prev = (commandline)
    if ($_prev != "") {
        print '⌛'
        commandline edit -r (aichat -e $_prev)
    }
}

$env.config.color_config = {
  separator: "#6e6a86"
  leading_trailing_space_bg: "#908caa"
  header: "#31748f"
  date: "#f6c177"
  filesize: "#c4a7e7"
  row_index: "#9ccfd8"
  bool: "#eb6f92"
  int: "#31748f"
  duration: "#eb6f92"
  range: "#eb6f92"
  float: "#eb6f92"
  string: "#908caa"
  nothing: "#eb6f92"
  binary: "#eb6f92"
  cellpath: "#eb6f92"
  hints: dark_gray

  shape_garbage: { fg: "#524f67" bg: "#eb6f92" }
  shape_bool: "#c4a7e7"
  shape_int: { fg: "#f6c177" attr: b }
  shape_float: { fg: "#f6c177" attr: b }
  shape_range: { fg: "#ebbcba" attr: b }
  shape_internalcall: { fg: "#9ccfd8" attr: b }
  shape_external: "#9ccfd8"
  shape_externalarg: { fg: "#31748f" attr: b }
  shape_literal: "#c4a7e7"
  shape_operator: "#ebbcba"
  shape_signature: { fg: "#31748f" attr: b }
  shape_string: "#31748f"
  shape_filepath: "#c4a7e7"
  shape_globpattern: { fg: "#c4a7e7" attr: b }
  shape_variable: "#f6c177"
  shape_flag: { fg: "#c4a7e7" attr: b }
  shape_custom: { attr: b }
}
