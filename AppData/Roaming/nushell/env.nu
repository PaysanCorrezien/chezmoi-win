if (which zoxide | is-empty) == false {
    let zoxide_cache = $"C:\\Users\\($env.USERNAME)\\AppData\\Local\\zoxide"
    if not ($zoxide_cache | path exists) {
        mkdir $zoxide_cache
    }
    zoxide init nushell | save --force $"($zoxide_cache)\\init.nu"
}

if (which starship | is-empty) == false {
    let starship_cache = $"C:\\Users\\($env.USERNAME)\\AppData\\Local\\starship"
    if not ($starship_cache | path exists) {
        mkdir $starship_cache
    }
    starship init nu | save --force $"($starship_cache)\\init.nu"
}

if (which carapace | is-empty) == false {
    let carapace_cache = $"C:\\Users\\($env.USERNAME)\\AppData\\Local\\carapace"
    if not ($carapace_cache | path exists) {
        mkdir $carapace_cache
    }
    carapace _carapace nushell | save -f $"($carapace_cache)\\init.nu"
}

if (which atuin | is-empty) == false {
    let atuin_cache = $"C:\\Users\\($env.USERNAME)\\AppData\\Local\\atuin"
    if not ($atuin_cache | path exists) {
        mkdir $atuin_cache
    }
    atuin init nu | save --force $"($atuin_cache)\\init.nu"
}

load-env {}
