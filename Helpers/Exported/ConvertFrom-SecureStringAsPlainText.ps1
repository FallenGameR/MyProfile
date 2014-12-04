param([System.Security.SecureString] $secureString = $(throw "Please specifiy a SecureString"))

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBstr($bstr)