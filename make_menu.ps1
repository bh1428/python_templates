#########################################################################################
# Name: make_menu.ps1                                                                   #
# Author: Ben Hattem (benghattem@gmail.com)                                             #
#                                                                                       #
# Versions:                                                                             #
#  1.0    2025-03-19  BHA  initial version                                              #
#  1.0.1  2025-03-19  BHA  minor refactoring                                            #
#  1.0.2  2025-03-19  BHA  change purple colors back to normal                          #
#  1.0.3  2025-03-20  BHA  do not set colors at all                                     #
#  1.0.4  2025-03-21  BHA  fix situation where no or only one make target is found      #
#                                                                                       #
# Purpose: menu for a makefile (every .PHONY target becomes an entry)                   #
#                                                                                       #
#########################################################################################

#
# CONFIGURATION
#
$config = [PSCustomObject]@{
    'version'    = '1.0.4'
    'scriptName' = $([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
}


#
# TEXT USER INTERFACE (TUI)
#
function Set-HostColors {
    $colors = @{
        'background' = 'Black'
        'foreground' = 'Gray'
        'error'      = 'Red'
        'highlight'  = 'Yellow'
    }
    $Host.UI.RawUI.BackgroundColor = $colors.background
    $Host.UI.RawUI.ForegroundColor = $colors.foreground
    $Host.PrivateData.ErrorForegroundColor = $colors.error
    $Host.PrivateData.ErrorBackgroundColor = $colors.background
    $Host.PrivateData.WarningForegroundColor = $colors.highlight
    $Host.PrivateData.WarningBackgroundColor = $colors.background
    $Host.PrivateData.DebugForegroundColor = $colors.highlight
    $Host.PrivateData.DebugBackgroundColor = $colors.background
    $Host.PrivateData.VerboseForegroundColor = $colors.highlight
    $Host.PrivateData.VerboseBackgroundColor = $colors.background
    $Host.PrivateData.ProgressForegroundColor = $colors.highlight
    $Host.PrivateData.ProgressBackgroundColor = $colors.background
    Clear-Host
}


function Get-MenuSelection {
    # initially based on: https://www.koupi.io/post/creating-a-powershell-console-menu
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$MenuItems,
        [switch]$ChooseByFirstLetter,
        [switch]$ExitWithX,
        [switch]$MultiSelect,
        [String]$MenuPrompt = 'Please choose:',
        [int]$Selected = 0,
        [String]$MenuLineStart = '  ',
        [String]$MultiSelMarker = 'x'
    )

    function Write-Menu {
        # reset the cursor position and write prompt
        $Host.UI.RawUI.CursorPosition = $initialCursorPosition
        Write-Host $MenuPrompt -ForegroundColor Green
        # show the menu
        for ($i = 0; $i -lt $Menu.Count; $i++) {
            if ($pos -eq $i) {
                Write-Host $Menu[$i] -ForegroundColor Blue -BackgroundColor Gray
            } else {
                Write-Host $Menu[$i]
            }
        }
    }

    # -ChooseByFirstLetter: get mapping from first letter to item
    $firstCharToPos = @{}
    foreach ($i in 0..($MenuItems.Count - 1)) {
        $item = $MenuItems[$i]
        if (-not [string]::IsNullOrWhiteSpace($item)) {
            $firstCharToPos[$item.Substring(0, 1).ToLower()] = $i
        }
    }

    # -Selected: check / set current item selection
    $pos = [Math]::Max(0, [Math]::Min($Selected, $MenuItems.Count - 1))

    # prepare menu for display
    $maxLineLength = ($MenuItems | Measure-Object -Property Length -Maximum).Maximum + 4
    if ($MultiSelect) {
        if ([string]::IsNullOrWhiteSpace($MultiSelMarker)) {
            throw 'Parameter -MultiSelMarker cannot be an empty string'
        }
        $multiSelectPos = $MenuLineStart.Length + 1
        $multiSelNotMarked = ' ' * $MultiSelMarker.Length
    }
    $Menu = @($MenuItems | ForEach-Object {
            $menuLine = $MenuLineStart
            if ($MultiSelect) {
                $menuLine += "[$multiSelNotMarked] "
            }
            $menuLine += "$_ " + (' ' * ($maxLineLength - $_.Length))
            $menuLine
        })

    # start menu
    $exitWithoutChoice = $false
    $virtKey = $null
    $initialCursorPosition = $host.UI.RawUI.CursorPosition

    while ($virtKey -ne 13) {
        Write-Menu
        $keyPress = $host.ui.rawui.readkey('NoEcho,IncludeKeyDown')
        $virtKey = $keyPress.virtualkeycode

        # handle key press
        switch ($virtKey) {
            { $_ -in 37..38 } { if ($pos -gt 0) { $pos-- } }  # Left/Up
            { $_ -in 39..40 } { if ($pos -lt $MenuItems.Count - 1) { $pos++ } }  # Right/Down
            36 { $pos = 0 }  # Home
            35 { $pos = $MenuItems.Count - 1 }  # End
            { $ExitWithX -and ([string]$keyPress.character).ToLower() -eq 'x' } {
                $exitWithoutChoice = $true
                $virtKey = 13  # simulate <enter>
            }
            { $ChooseByFirstLetter -and $firstCharToPos.ContainsKey(([string]$keyPress.character).ToLower()) } {
                $pos = $firstCharToPos[([string]$keyPress.character).ToLower()]
                $virtKey = if ($MultiSelect) { 32 } else { 13 }  # simulate <space> or <enter>
            }
        }

        # -MultiSelect (when enabled): triggered by <space>
        if ($MultiSelect -and $virtKey -eq 32) {
            $currentSelect = $Menu[$pos].Substring($multiSelectPos, $MultiSelMarker.Length)
            $newSelect = if ($currentSelect -eq $MultiSelMarker) { $multiSelNotMarked } else { $MultiSelMarker }
            $Menu[$pos] = $Menu[$pos].Substring(0, $multiSelectPos) + $newSelect + $Menu[$pos].Substring($multiSelectPos + $MultiSelMarker.Length)
        }
    }

    if (-not $exitWithoutChoice) {
        # a choice was made: evaluate
        if ($MultiSelect) {
            # get all selected entries when in -MultiSelect mode
            $selection = for ($i = 0; $i -lt $Menu.Count; $i++) {
                if ($Menu[$i].substring($multiSelectPos, $MultiSelMarker.Length) -eq $MultiSelMarker) {
                    $MenuItems[$i]
                }
            }
            # return when at least one item is selected (otherwise return $null)
            if ($selection.Count -gt 0) {
                return $selection
            }
        } else {
            return $MenuItems[$pos]
        }
    }
    return $null
}


function Read-AnyKey {
    param (
        [string]$Prompt = 'Press any key to continue...'
    )
    Write-Host -NoNewline $Prompt
    # ignore keys like Alt, Ctrl, Shift, Tab, etc...
    $ignoreKeys = @(
        9, 16, 17, 18, 20, 91, 92, 93, 144, 145, 166, 167, 168, 169, 170,
        171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183
    )
    $keyPress = $null
    while ($null -eq $keyPress.VirtualKeyCode -or $ignoreKeys -contains $keyPress.VirtualKeyCode) {
        $keyPress = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown')
    }
    Write-Host
}


function Write-Underlined {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [string]$UnderlineChar = '-'
    )
    Write-Host $Text
    $underline = $UnderlineChar * $Text.Length
    Write-Host $underline
}


#
# MAIN FUNCTIONS
#
function New-MakeMenu {
    param (
        [String]$Makefile = 'makefile'
    )
    if (-not (Test-Path $Makefile)) {
        throw "-Makefile: '${Makefile}' not found"
    }
    $phonies = @(Select-String -Path $Makefile -Pattern '^\s*\.PHONY:\s*(.+)' |
            ForEach-Object { $($_.Matches[0] -split '\s+')[1] } |
            Select-Object -Unique)
    $fastChoices = '123456789abcdefghijklmnopqrstuvw'
    $menu = [ordered]@{}
    for ($i = 0; $i -lt $phonies.Length; $i++) {
        if ($phonies.Length -le $fastChoices.Length) {
            $menuItem = "$($fastChoices[$i])) $($phonies[$i])"
        } else {
            $menuItem = $phonies[$i]
        }
        $menu[$menuItem] = $phonies[$i]
    }
    return $menu
}


function Invoke-MakeMenu {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary]$Menu
    )
    $menuPosition = 0
    $exitNotChosen = $true
    $prompt = "$($config.scriptName) (V$($config.version)) - choose 'make' action ('x'=exit):"
    while ($exitNotChosen) {
        Clear-Host
        $choice = Get-MenuSelection -MenuItems $Menu.Keys -MenuPrompt $prompt `
            -ChooseByFirstLetter -ExitWithX -Selected $menuPosition
        if ($null -eq $choice) {
            $exitNotChosen = $false
        } else {
            $makeTarget = $($Menu[$choice])
            Clear-Host
            Write-Underlined "make $makeTarget"
            & make $makeTarget
            Write-Host
            Read-AnyKey
        }
    }
}


#
# MAIN
#
try {
    $ErrorActionPreference = 'Continue'

    $makeMenu = New-MakeMenu
    if ($makeMenu.Count -eq 0) {
        throw 'No make targets found.'
    }
    Invoke-MakeMenu -Menu $makeMenu
} catch {
    Write-Host "`nGot an unhandled error (execution will be stopped):"
    Write-Host -ForegroundColor Red $_
    Write-Host
    Write-Host -ForegroundColor Red $_.InvocationInfo.PositionMessage
    Write-Host
    Write-Host -ForegroundColor Red 'StackTrace:'
    Write-Host -ForegroundColor Red $_.ScriptStackTrace
    Write-Host
    Read-AnyKey -Prompt 'Press any key to EXIT...'
    exit 1
}
exit 0