function ilspy
{
    & "c:\tools\ILSpy\ILSpy.exe"
}

function qbuddy
{
    del d:\autopilot\outgoing.dpk
    git sdp pack d:\autopilot\outgoing.dpk master...HEAD
    & d:\clientGoldEnlistment\Q\client\quickbuild.exe -buddy -dpk d:\autopilot\outgoing.dpk
}

filter nman( $template )
{
    if( $psitem -match $template )
    {
        $psitem | hl $template
    }
}

function devenv
{
    if( -not $args )
    {
        $file = @(ls "*.csproj")
        if( $file.Count -eq 1 )
        {
            & "c:\programs\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe" $file[0]
        }
        else
        {
            throw "use arguments, there are several projects in this folder"
        }
    }

    & "c:\programs\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe" $args
}
