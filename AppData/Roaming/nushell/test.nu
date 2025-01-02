let $myurl = "http://console_inf.bijou.com/console.html"
def parse_entry [entry: string, info_lvl: string] {
    let parts = ($entry | split row '-*-' | each { |part| $part | str trim })
    {
        INFO_lvl: $info_lvl,
        timestamp: ($parts | get 0),
        message: ($parts | get 1 | default "")
    }
}

let red_entries = (http get $myurl | 
  decode iso-8859-1 | 
  parse --regex '<p><font size=2 color="red">(.*?)</font></p>' | 
  get capture0 |
  each { |it| parse_entry $it "urgent" })

let other_entries = (http get $myurl | 
  decode iso-8859-1 | 
  parse --regex '<p><font size=2>(.*?)</font></p>' | 
  get capture0 |
  each { |it| parse_entry $it "normal" })

$red_entries | append $other_entries | sort-by INFO_lvl timestamp | reverse |
each { |entry|
    let color = if $entry.INFO_lvl == "urgent" { "red" } else { "blue" }
    {
        INFO_lvl: $"(ansi $color)($entry.INFO_lvl)(ansi reset)",
        timestamp: $entry.timestamp,
        message: $entry.message
    }
} | table
