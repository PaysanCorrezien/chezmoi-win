# commit-oracle.ps1

# Helper function to escape special characters
function Escape-StringForCmd
{
  param([string]$String)
  return $String.Replace('"', '\"').Replace('`', '\`').Replace('$', '`$')
}

# Get the staged diff and recent commits
$diff = git --no-pager diff --no-color --no-ext-diff --cached
$recentCommits = git log -n 10 --pretty=format:'%h %s'

# Escape the diff for the prompt
$escapedDiff = Escape-StringForCmd $diff

$prompt = @"
Please suggest 5 commit messages, given the following diff:

```diff
$escapedDiff
```

**Criteria:**

1. **Format:** Each commit message must follow the 
  commitizen conventional commits format, which is:
```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

2. **Relevance:** Avoid mentioning a module name unless it's directly relevant
to the change.
3. **Enumeration:** List the commit messages from 1 to 5.
4. **Clarity and Conciseness:** Each message should clearly and concisely convey
the change made.

**Recent Commits on Repo for Reference:**

```
$recentCommits
```

**Output Template**

Follow this output template and ONLY output raw commit messages without
numbers or other decorations. Separate each commit message with '---'.

fix(app): add password regex pattern
---
style: remove unused imports
---
refactor(pages): extract common code to 'utils/wait.ts'
---
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.
---
test(unit): add new test cases
"@


try
{
  # Create temporary files with unique names
  $commitMsgFile = [System.IO.Path]::GetTempFileName()
  $suggestionsFile = [System.IO.Path]::GetTempFileName()

  # Get commit suggestions from aichat and process them
  $suggestions = aichat $prompt
    
  # Split suggestions by --- and clean up the output
  $suggestions -split '(?m)^---\s*$' | 
    Where-Object { $_.Trim() } | 
    ForEach-Object { ($_.Trim() + "`0") } | 
    Out-File $suggestionsFile -Encoding utf8 -NoNewline

  # Use fzf with two different key bindings for different actions
  $selected = Get-Content $suggestionsFile -Raw | 
    fzf --height 20 --border --ansi --read0 --no-sort `
      --preview "echo {}" `
      --preview-window=up:wrap `
      --expect=ctrl-y `
      --header "Enter: edit in nvim | Ctrl+Y: commit directly"

  if ($selected)
  {
    # fzf --expect returns two lines: the key pressed and the selection
    $key, $choice = $selected -split "`n", 2
        
    # Remove the null terminator from the choice
    $choice = $choice -replace '\0', ''
        
    if ($choice)
    {
      if ($key -eq "ctrl-y")
      {
        # Direct commit without editor
        $choice | Out-File $commitMsgFile -Encoding utf8 -NoNewline
        Write-Host "Committing directly with message:"
        Write-Host $choice
        git commit -F $commitMsgFile
      } else
      {
        # Normal flow with editor
        $choice | Out-File $commitMsgFile -Encoding utf8 -NoNewline
        $beforeTime = (Get-Item $commitMsgFile).LastWriteTime
                
        if ($env:EDITOR)
        {
          & $env:EDITOR $commitMsgFile
        } else
        {
          notepad $commitMsgFile
        }
                
        $afterTime = (Get-Item $commitMsgFile).LastWriteTime
                
        if ($beforeTime -ne $afterTime)
        {
          $finalMessage = Get-Content $commitMsgFile -Raw
          if ($finalMessage.Trim())
          {
            git commit -F $commitMsgFile
          } else
          {
            Write-Host "Commit message is empty, commit aborted."
          }
        } else
        {
          Write-Host "Commit message was not saved, commit aborted."
        }
      }
    }
  }
} catch
{
  Write-Error "An error occurred: $_"
} finally
{
  # Cleanup temporary files
  if (Test-Path $suggestionsFile)
  { Remove-Item $suggestionsFile 
  }
  if (Test-Path $commitMsgFile)
  { Remove-Item $commitMsgFile 
  }
}
