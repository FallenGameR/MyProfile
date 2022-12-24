$SCRIPT:stopwatch = [system.diagnostics.stopwatch]::StartNew()
$SCRIPT:enableTiming = $true

function SCRIPT:tm($info = "=>")
{
    if( $SCRIPT:enableTiming )
    {
        Write-Host "$($SCRIPT:stopwatch.ElapsedMilliseconds / 1000) $info"
        $SCRIPT:stopwatch.Restart()
    }
}

function SCRIPT:Import-AsDotSource($path, $condition = $true)
{
    if( -not $condition ) { return }
    if( -not (Test-Path $path) ) { return }
    . $path
}

function SCRIPT:Import-AsInvoke($path, $condition = $true)
{
    if( -not $condition ) { return }
    if( -not (Test-Path $path) ) { return }
    & $path
}

tm (Split-Path $PSCommandPath -Leaf)