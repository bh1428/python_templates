# Use cookiecutter to create a project from a template
#
# V1.0    2022-03-03  initial version
# V1.1    2022-03-18  add 'x' (exit) option to menu
# V1.1.1  2025-03-21  update TUI with newer version

#
# CONFIGURATION
#
$config = @{
    'COOKIECUTTER'  = 'cookiecutter.exe'
    'TEMPLATE_DIRS' = '.\python_templates'
    'TEMPLATES'     = [ordered]@{}
}

# end of configuration


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
# FUNCTIONS
#
function Get-Templates {
    param(
        [ValidateNotNullOrEmpty()]
        [HashTable]$Config
    )
    $templates = @{}
    foreach ($templateDir in Get-ChildItem -Directory -Exclude .git -Path $Config.TEMPLATE_DIRS) {
        $template = Join-Path -Path $templateDir -ChildPath cookiecutter.json
        if (Test-Path -Path $template) {
            $templateInfo = Get-Content $template -Raw | ConvertFrom-Json
            $templates.Add($templateInfo.repo_name, $templateDir)
        }
    }
    $templates.getEnumerator() | Sort-Object -Property key | ForEach-Object {
        $Config.TEMPLATES.Add($_.key, $_.value)
    }
    return $Config
}


function Invoke-Cmd {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$CmdExe,
        [ValidateNotNullOrEmpty()]
        [string]$Msg,
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Write-Underlined $Msg '-'
    & $CmdExe $Arguments
    if ($?) {
        Write-Host ''
    } else {
        Throw "could not $Msg"
    }
}

#
# MENU AND ACTION HANDLERS
#
function Invoke-Cookiecutter {
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Template,
        [ValidateNotNullOrEmpty()]
        [HashTable]$Config
    )
    Clear-Host
    Invoke-Cmd -CmdExe $Config.COOKIECUTTER -Msg "creating project for template: $Template" "$($Config.TEMPLATES[$Template])"
    Read-AnyKey
}


function New-MainMenu {
    param(
        [ValidateNotNullOrEmpty()]
        [HashTable]$Config
    )
    $menu = [ordered]@{}
    foreach ($template in $Config.TEMPLATES.keys) {
        $menu.Add($template, $template)
    }
    $menu.Add('Exit (do nothing)', 'EXIT')
    return $menu
}


function Show-MainMenu {
    param(
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary]$Menu,
        [ValidateNotNullOrEmpty()]
        [HashTable]$Config
    )
    $exitNotChosen = $true
    while ($exitNotChosen) {
        Clear-Host
        $choice = Get-MenuSelection -MenuItems $Menu.Keys -MenuPrompt 'Create project from cookiecutter template (''x'' to exit):' -ExitWithX
        if (($null -eq $choice) -or ($Menu[$choice] -eq 'EXIT')) {
            $exitNotChosen = $false
        } else {
            Invoke-Cookiecutter -Template $Menu[$choice] -Config $Config
        }
    }
}

#
# MAIN
#
try {
    $ErrorActionPreference = 'Continue'

    $config = Get-Templates -Config $config
    $menu = New-MainMenu -Config $config
    Show-MainMenu -Menu $menu -Config $config
} catch {
    Write-Host "`nGot an unhandled error (execution will be stopped):"
    Write-Host -ForegroundColor Red $_
    Write-Host
    Write-Host -ForegroundColor Red $_.InvocationInfo.PositionMessage
    Write-Host
    Write-Host -ForegroundColor Red 'StackTrace:'
    Write-Host -ForegroundColor Red $_.ScriptStackTrace
    Write-Host
    Read-AnyKey
    exit 1
}
exit 0