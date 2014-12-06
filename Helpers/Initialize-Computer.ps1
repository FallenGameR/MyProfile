# Test if initialization is needed
$initializedFile = Join-Path (Split-Path $PROFILE) "initialized"
$initialized = Test-Path $initializedFile
if( $initialized )
{
    return
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
    mkdir "c:\tools" -ea Stop
}






# tools junction creation
# folder hide
# orogram files function
# where is gite?
# why git files beome corrupted?
# environment variables setup - for total commander shortcuts


Write-Host $initialized -fore cyan
