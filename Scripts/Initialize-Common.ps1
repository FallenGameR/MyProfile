# Modules in profile subfolder
$modules = Join-Path (Split-Path $profile) Modules
if( -not $env:PSModulePath.Contains($modules) )
{
    $env:PSModulePath += [io.path]::PathSeparator + $modules
}

# PSToolset module
Complete-Once PSToolset {
    pushd $PsScriptRoot/../Modules
    git clone https://github.com/microsoft/PSToolset.git
    popd
}

# Default command arguments
$PSDefaultParameterValues["Get-Command:All"] = $true

# Aliases
Set-Alias m Measure-Object
Set-Alias ls Get-ChildItem

# Common tools setup
$env:LESS = "-IeFRX"
$env:RIPGREP_CONFIG_PATH = "$PSScriptRoot\..\rg.config"
$env:BAT_CONFIG_PATH = "$PSScriptRoot\..\bat.config"

# Colors
if( Test-Full )
{
    # For some reason they changed progress color in PS 7.1.1
    $host.PrivateData.ProgressForegroundColor = "White"
    $host.PrivateData.ProgressBackgroundColor = "DarkCyan"
}

tm (Split-Path $PSCommandPath -Leaf)