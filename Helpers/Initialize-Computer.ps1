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
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "e:\OneDrive\"
        $oneDriveMicrosoft = "e:\OneDriveMicrosoft\"
    }
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\SkyDrive @ Microsoft\"
    }
    "TACHIKOMA"
    {
        $dropbox = "d:\Dropbox\"
        $oneDrive = "d:\OneDrive\"
        $oneDriveMicrosoft = $null
    }
}

# TODO: test that we have admin rights?
# or better - test that current user can do anything to drive c:\

# Tools folder creation
if( -not (Test-Path "c:\tools") )
{
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
# orogram files function
# environment variables setup - for total commander shortcuts
# shortcut creation

