# Test if initialization is needed
$initializedFile = Join-Path (Split-Path $PROFILE) "initialized"
$initialized = Test-Path $initializedFile
if( $initialized )
{
    return
}

# Helper functions
function New-Junction( $from, $to )
{
    # Set-junction is needed instead
    cmd /c "mklink /J ""$To"" ""$From"""
}

filter Set-Visible( [bool] $makeVisible )
{
    # TODO: debug
    $attributes = (Get-ItemProperty $psitem).Attributes
    $hidden = $attributes -band [Io.Fileattributes]::Hidden
    if( $hidden -xor $makeVisible )
    {
        Set-ItemProperty `
            -Path $psitem `
            -Name Attributes `
            -Value ($attributes -bxor [Io.Fileattributes]::Hidden)
    }
}

# Cloud folders setup
switch ($env:ComputerName)
{
    "ALEXKO-DEV"
    {
        $dropbox = "e:\Dropbox\"
        $oneDrive = "e:\OneDrive\"
        $oneDriveMicrosoft = "e:\OneDriveMicrosoft\"
        $opensource = $null
        $azcompute = $null
        $apgold = $null
        $root = $null
    }
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\SkyDrive @ Microsoft\"
        $opensource = "c:\src\opensource\"
        $azcompute = "c:\src\autopilot\az_compute\"
        $apgold = "c:\src\autopilot\apgold_sd\"
        $root = "c:\src\root\"
    }
    "TACHIKOMA"
    {
        $dropbox = "d:\Dropbox\"
        $oneDrive = "d:\OneDrive\"
        $oneDriveMicrosoft = $null
        $opensource = $null
        $azcompute = $null
        $apgold = $null
        $root = $null
    }
}

# Set up environment variables
function Set-EnvironmentVariable( $name, $value )
{
    if( (Get-Item env:$name -ea Ignore).Value -ne $value )
    {
        [Environment]::SetEnvironmentVariable( $name, $value, "User" )
        Set-Item env:$name $value
    }
}
Set-EnvironmentVariable "Dropbox" $dropbox
Set-EnvironmentVariable "OneDrive" $oneDrive
Set-EnvironmentVariable "OneDriveMicrosoft" $oneDriveMicrosoft
Set-EnvironmentVariable "Opensource" $opensource
Set-EnvironmentVariable "AzCompute" $azcompute
Set-EnvironmentVariable "ApGold" $apgold
Set-EnvironmentVariable "Root" $root
Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Tools folder creation
if( -not (Test-Path "c:\tools") )
{
    # Do we need to test that we have admin rights / that current user can do anything to drive c:\ ?
    mkdir "c:\tools" -ea Stop | Out-Null
}

# Tools junction creation
foreach( $tool in ls $dropbox\tools -Directory | where Name -notmatch "^_" )
{
    $to = "c:\tools\$($tool.Name)"
    if( -not (Test-Path $to) )
    {
        New-Junction $tool.FullName $to
    }
}

# folder hide
# program files function
# shortcut creation
# c:\tools\Multitran\network\ to path
