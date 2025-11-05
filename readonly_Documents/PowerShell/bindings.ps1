# Import PSReadLine if not already imported
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Import-Module PSReadLine
}

## Set https://github.com/kelleyma49/PSFzf/blob/master/docs/Set-PsFzfOption.md

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PsFzfOption -EnableAliasFuzzyHistory
Set-PsFzfOption -EnableAliasFuzzyScroop
Set-PsFzfOption -EnableAliasFuzzyEdit

## Tab expension

# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -ScriptBlock {

  $ast = $tokens = $errors = $cursor = $null

  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $line = $ast.Extent.Text

  # Add your custom behavior here

  Invoke-PsFzfRipgrep -SearchString $line

}

# Undo the last editing command
Set-PSReadLineKeyHandler -Key Ctrl+u -Function Undo

# Placeholder for Custom Edit Command Function (see below for implementation)
# Set-PSReadLineKeyHandler -Key Ctrl+e -ScriptBlock { Edit-CurrentLineInEditor }

# Navigate up in the command history
Set-PSReadLineKeyHandler -Key Ctrl+k -Function PreviousHistory

# Navigate down in the command history
Set-PSReadLineKeyHandler -Key Ctrl+j -Function NextHistory

# Clear the current line
Set-PSReadLineKeyHandler -Key Ctrl+d -Function RevertLine

# Move to the start of the previous word
Set-PSReadLineKeyHandler -Key Ctrl+b -Function BackwardWord

# Move to the end of the next word
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardWord

# Delete the word after the cursor
Set-PSReadLineKeyHandler -Key Ctrl+w -Function KillWord

# Delete the word before the cursor
Set-PSReadLineKeyHandler -Key Ctrl+x -Function BackwardKillWord

# Redo the last undone editing command
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo

# function Edit-CustomEditor {
#     param(
#         [string]$Editor = $env:EDITOR,
#         [string]$Extension = "ps1"
#     )
#
#     $tempFile = [System.IO.Path]::GetTempFileName()
#     $tempFileWithExtension = [System.IO.Path]::ChangeExtension($tempFile, $Extension)
#
#     # Get the current command line content
#     $ast = $tokens = $errors = $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
#     $currentLine = $ast.Extent.Text
#
#     # Save to temp file with the specified extension
#     [System.IO.File]::WriteAllText($tempFileWithExtension, $currentLine)
#
#     # Start NeoVim in a new PowerShell process
#     $nvimProcess = Start-Process -FilePath "pwsh.exe" -ArgumentList "-Command & `"$Editor`" `"$tempFileWithExtension`"" -PassThru
#
#     # Use a background job to wait for the NeoVim process to exit
#     $job = Start-Job -ScriptBlock {
#         param($processId, $tempFileWithExtension)
#         $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
#         while ($null -ne $process) {
#             Start-Sleep -Seconds 1
#             $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
#         }
#         Get-Content -Path $tempFileWithExtension
#     } -ArgumentList $nvimProcess.Id, $tempFileWithExtension
#
#     # Wait for the job to complete and get the result
#     $modifiedCommand = Receive-Job -Job $job -Wait
#     Remove-Job -Job $job
#
#     # Update the PowerShell command line
#     [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#     [Microsoft.PowerShell.PSConsoleReadLine]::Insert($modifiedCommand)
#
#     # Clean up
#     Remove-Item -Path $tempFileWithExtension
# }

# Bind Ctrl+E to the custom edit command function
# Set-PSReadLineKeyHandler -Key Ctrl+e -ScriptBlock { Edit-CustomEditor }

Set-PSReadLineKeyHandler -Chord Ctrl+e -Function ViEditVisually
# use history as the prediction source
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
# show predictions in a pop-up list
Set-PSReadLineOption -PredictionViewStyle ListView

# bind Ctrl+P / Ctrl+N to navigate that list
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function PreviousSuggestion
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function NextSuggestion

#Set-PSReadLineKeyHandler -Chord Ctrl+h -Function ShowParameterHelp
