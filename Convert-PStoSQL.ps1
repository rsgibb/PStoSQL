<#
.SYNOPSIS
    Converts parameters to SQL script
.DESCRIPTION
    Converts parameters to SQL script 
.EXAMPLE
    Convert-PStoSQL -Select 'User' -Where {
        UserId -eq 'howler'
    }
    Selects a user from the table user where UserId = 'howler'
.INPUTS
    [string]$Select
    [string]$Insert
    [string]$Update
    [string]$Delete
.OUTPUTS
    [string] SQLCommand
.NOTES
    ...
#>

function Convert-PStoSQL {
    [CmdletBinding(DefaultParameterSetName = 'Select')]
    param(
        # SELECT (FROM) <table>
        [Parameter(
            ParameterSetName = 'Select',
            Position = 0

        )]
        [string]$Select,    
        # INSERT (INTO) <table>
        [Parameter(
            ParameterSetName = 'Insert',
            Position = 0

        )]
        [string]$Insert,    
        # UPDATE <table>
        [Parameter(
            ParameterSetName = 'Update',
            Position = 0

        )]
        [string]$Update,    
        # DELETE (FROM) <table>
        [Parameter(
            ParameterSetName = 'Delete',
            Position = 0

        )]
        [string]$Delete,    
    
    
        # The SQL command (select, insert, update, delete)
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet('Select', 'Insert', 'Update', 'Delete')]
        [string]$Command,
        # The table
        [Parameter()]
        [ValidateNotNullOrEmpty]
        [string]$Table,
        # Where cause in script block to convert to SQL
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty]
        [ScriptBlock]$Where
    )

    $sql = 

    $tokens = [System.Management.Automation.PSParser]::Tokenize($Where, [ref]$null)

    $whereSql = foreach ($token in $tokens) {

    }
}