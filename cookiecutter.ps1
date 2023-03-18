# Use cookiecutter to create a project from a template
#
# V1.0   2022-03-03 initial version
# V1.1   2022-03-18 add 'x' (exit) option to menu

#
# CONFIGURATION
#
$config = @{
    'COOKIECUTTER' = 'cookiecutter.exe'
    'TEMPLATE_DIRS' = '.\python_templates'
    'TEMPLATES' = [ordered]@{}
}

# end of configuration


#
# USERINTERFACE
#
function Set-HostColors {
    $background = 'DarkMagenta'
    $Host.UI.RawUI.BackgroundColor = $background
    $Host.UI.RawUI.ForegroundColor = 'DarkYellow'
    $Host.PrivateData.ErrorForegroundColor = 'Red'
    $Host.PrivateData.ErrorBackgroundColor = $background
    $Host.PrivateData.WarningForegroundColor = 'Yellow'
    $Host.PrivateData.WarningBackgroundColor = $background
    $Host.PrivateData.DebugForegroundColor = 'Yellow'
    $Host.PrivateData.DebugBackgroundColor = $background
    $Host.PrivateData.VerboseForegroundColor = 'Yellow'
    $Host.PrivateData.VerboseBackgroundColor = $background
    $Host.PrivateData.ProgressForegroundColor = 'Yellow'
    $Host.PrivateData.ProgressBackgroundColor = $background
}


function Get-MenuSelection {
    # based on: https://www.koupi.io/post/creating-a-powershell-console-menu
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [ValidateNotNullOrEmpty()]
        [String[]]$MenuItems,
        [String]$MenuPrompt,
        [switch]$ChooseByFirstLetter,
        [switch]$ExitWithX,
        [int]$Selected = 0
    )

    # get mapping from (lowercase) first key to item
    $firstCharToPos = @{}
    for($i=0; $i -lt $MenuItems.Count; $i++) {
        if ($MenuItems[$i] -notmatch '^\s*$') {
            $firstCharToPos[$MenuItems[$i].substring(0,1).tolower()] = $i
        }
    }

    # store initial cursor position
    $cursorPosition = $host.UI.RawUI.CursorPosition
    $pos = $Selected # current item selection
    if ($pos -lt 0) {
        $pos = 0
    } elseif ($pos -ge $MenuItems.Count) {
        $pos = $MenuItems.Count - 1
    }

    function Write-Menu {
        param (
            [int]$selectedItemIndex
        )
        # reset the cursor position and write prompt
        $Host.UI.RawUI.CursorPosition = $cursorPosition
        Write-Host $MenuPrompt -ForegroundColor Green

        # write the menu lines
        $maxLineLength = ($MenuItems | Measure-Object -Property Length -Maximum).Maximum + 4
        for ($i=0; $i -lt $MenuItems.Count; $i++) {
            $line = "    $($MenuItems[$i])" + (' ' * ($maxLineLength - $MenuItems[$i].Length))
            if ($selectedItemIndex -eq $i) {
                Write-Host $line -ForegroundColor Blue -BackgroundColor Gray
            } else {
                Write-Host $line
            }
        }
    }

    Write-Menu -selectedItemIndex $pos
    $virtKey = $null
    $exitWithoutChoice = $false
    while ($virtKey -ne 13) {
        # handle keypress
        $keyPress = $host.ui.rawui.readkey('NoEcho,IncludeKeyDown')
        $virtKey = $keyPress.virtualkeycode
        if ((37, 38) -contains $virtKey -and $pos -gt 0) {  # cursor left / cursor up
            $pos--
        } elseif ((39, 40) -contains $virtKey -and $pos -lt $MenuItems.Count-1) {  # cursor right / cursor down
            $pos++
        } elseif ($virtKey -eq 36) {  # Home
            $pos = 0
        } elseif ($virtKey -eq 35) {  # End
            $pos = $MenuItems.Count - 1
        } elseif ($ExitWithX -and ([string]$keyPress.character).tolower() -eq 'x'){
            $exitWithoutChoice = $true
            $virtKey = 13
        } elseif ($ChooseByFirstLetter -and $firstCharToPos.keys -contains ([string]$keyPress.character).tolower()) {
            $pos = $firstCharToPos[([string]$keyPress.character).tolower()]
            $virtKey = 13
        }
        Write-Menu -selectedItemIndex $pos
    }

    if ($exitWithoutChoice) {
        return $null
    } else {
        return $MenuItems[$pos]
    }
}


function Read-AnyKey {
    Write-Host -NoNewline 'Press any key to continue...'
    # ignore keys like Alt, Ctrl, Shift, Tab, etc...
    $ignore = 9, 16, 17, 18, 20, 91, 92, 93, 144, 145, 166, 167, 168, 169, `
        170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183
    $keyPress = $null
    while ($null -eq $keyPress.VirtualKeyCode -or $ignore -contains $keyPress.VirtualKeyCode) {
        $keyPress = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown')
    }
    Write-Host
}


function Write-Underlined {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [string]$UnderlineChar='-'
    )
    Write-Host ($Text.substring(0, 1).toupper() + $Text.substring(1))
    $underline = $UnderlineChar * $Text.length
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
    $templates.getEnumerator() | Sort-Object -property key | ForEach-Object {
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
    clear
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
        clear
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