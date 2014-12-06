# Test if initialization is needed
$initializedFile = Join-Path (Split-Path $PROFILE) "initialized"
$initialized = Test-Path $initializedFile
if( $initialized )
{
    return
}

# Helper function
function New-Junction( $from, $to )
{
    cmd /c "mklink /J ""$To"" ""$From"""
}

# Cloud folders setup
switch ($env:ComputerName)
{
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\SkyDrive @ Microsoft\"
    }
}

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


Write-Host $initialized -fore cyan
