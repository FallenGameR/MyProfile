@{
    'Rules' = @{
        'PSAvoidUsingCmdletAliases' = @{
            'Whitelist' = @(
                "ls", "cd", "where",
                "foreach", "select", "copy")
        }
    }
}
