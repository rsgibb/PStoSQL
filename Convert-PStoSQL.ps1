<#
.SYNOPSIS
    Converts parameters to SQL script
.DESCRIPTION
    Converts PowerShell parameters to SQL script for basic CRUD operations
.EXAMPLE
    Convert-PStoSQL -Select UserId,Firstname,Surname -From tblUser -Where {
        UserId -eq 'rsgibb'
    }
    Outputs SQL query that will selects 3 columns from the table tblUser where UserId = 'rsgibb'
.INPUTS
.OUTPUTS
    SQL query/statement
.NOTES
    ...
#>

<#
TODO
 * Support arrays for IN (...) operator
 * Quote and escape values in $Set and $Values
 * Propably other things to make this more 'complete'
#>

function Convert-PStoSQL {
    [CmdletBinding(DefaultParameterSetName = 'Select')]
    param(
        # SELECT <column, ...> 
        [Parameter(
            ParameterSetName = 'Select',
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Select, 

        # FROM <table>
        [Parameter(
            ParameterSetName = 'Select',
            Position = 1,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $From,
        
        # INSERT INTO <table>
        [Parameter(
            ParameterSetName = 'Insert',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $InsertInto,    

        # VALUES
        [Parameter(
            ParameterSetName = 'Insert',
            Position = 1,
            Mandatory = $true
        )]
        [hashtable]
        $Values,
        
        # UPDATE <table>
        [Parameter(
            ParameterSetName = 'Update',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Update,
        
        # SET <key> = <value>
        [Parameter(
            ParameterSetName = 'Update',
            Position = 1,
            Mandatory = $true
        )]
        [hashtable]
        $Set,

        # DELETE FROM <table>
        [Parameter(
            ParameterSetName = 'Delete',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $DeleteFrom,

        # Where cause in script block to convert to SQL
        [Parameter(
            ParameterSetName = 'Select',
            Position = 2,
            Mandatory = $true
        )]
        [Parameter(
            ParameterSetName = 'Update',
            Position = 2,
            Mandatory = $true
        )]
        [Parameter(
            ParameterSetName = 'Delete',
            Position = 1,
            Mandatory = $true
        )]
        [ScriptBlock]
        $Where
    )

    $operatorMap = @{
        '-eq'  = '='
        '-ne'  = '!='
        '-gt'  = '>'
        '-lt'  = '<'
        '-ge'  = '>='
        '-le'  = '<='
        '-or'  = 'OR'
        '-and' = 'AND'
        '-not' = 'NOT'
        '-in'  = 'IN'
    }

    $tokenTypeSets = @{
        Raw      = @(
            'Command'
            'CommandArgument'
            'GroupStart'
            'GroupEnd'
            'Number'
            'Variable'
        )

        Operator = @(
            'Operator'
            'CommandParameter'
        )

        Quoted   = @(
            'String'
        )
    }

    $tokenSeperator = ' '

    if ($Where) {
        $tokens = [System.Management.Automation.PSParser]::Tokenize($Where, [ref]$null)
        $whereSql = foreach ($token in $tokens) {
            foreach ($kvp in $tokenTypeSets.GetEnumerator()) {
                if ($token.Type -in $kvp.Value) {
                    switch ($kvp.Key) {
                        'Raw' { 
                            $token.Content
                        }
                        'Operator' {
                            $operatorMap[$token.Content]
                        }
                        'Quoted' {
                            "'{0}'" -f $token.Content
                        }
                    }            
                }
            }
        }
    }


    $sql = switch ($PSCmdlet.ParameterSetName) {
        'Select' {
            "SELECT`n`  {0}" -f ($Select -join ",`n  ")
            "FROM {0}" -f $From
            "WHERE {0}" -f ($whereSql -join $tokenSeperator)
        }

        'Insert' {
            "INSERT INTO {0} ({1})" -f $InsertInto, ($Values.Keys -join ',')
            "VALUES ({2})" -f $Values.Values # TODO: Quote and excape 
        }

        'Update' {
            "UPDATE {0}" -f $Update
            "SET {0}" -f ($Set.Keys -join ',') # TODO: Key & values
            "WHERE {0}" -f ($whereSql -join $tokenSeperator)
        }

        'Delete' {
            "DELETE FROM {0}" -f $DeleteFrom
            "WHERE {0}" -f ($whereSql -join $tokenSeperator)
        }
    }

    $sql -join [System.Environment]::NewLine
}

