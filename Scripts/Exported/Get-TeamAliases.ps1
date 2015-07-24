#
# Get all aliases that belong to specified Active Directory group
#

param
(
    [string] $alias = "apilotd"
)

function Get-Members( [string] $groupAlias )
{
    $ntAccount = New-Object Security.Principal.NTAccount($env:USERDOMAIN, $groupAlias)
    $sid = $ntAccount.Translate([Security.Principal.SecurityIdentifier])
    $ldap = [adsi] "LDAP://<SID=$sid>"
    $ldap.member
}

function Get-AliasesRecursive( [string] $rootAlias )
{
    foreach( $member in Get-Members $rootAlias )
    {
        $ldap = [adsi] "LDAP://$member"

        if( $ldap.member )
        {
            Get-AliasesRecursive $ldap.mailNickname
        }
        else
        {
            $ldap.mailNickname
        }
    }
}

Get-AliasesRecursive $alias | sort -Unique

