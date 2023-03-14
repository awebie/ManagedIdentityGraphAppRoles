Function Get-GraphAppRoles {
   <#
.SYNOPSIS
    Gets a list of Permission Scopes or "AppRoles" for Microsoft Graph.

.DESCRIPTION
    The `Get-GraphAppRoles` function retrieves a list of app roles for a Microsoft Graph Service Principal, using the Microsoft Graph PowerShell module. 

.PARAMETER Search
    Filters the results to only include app roles that match the specified search string. This parameter is optional.

.EXAMPLE
    Get-GraphAppRoles -Search "Device"
    This example retrieves a list of app roles for the Microsoft Graph Service Principal and filters the results to include only roles that have "searchterm" in the scope name.

.NOTES
    Author: Alec Weber 
    Date: 03/14/2023
#> 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Search")]
        [string]
        [ValidateNotNullOrEmpty()]$Search
    )
    if ($Null -eq (Get-MgContext)) {
        Connect-MgGraph -Scopes "Directory.Read.All"
    }
    else {
        if ((Get-Mgcontext).Scopes -notcontains "Directory.Read.All") {
            Connect-MgGraph -Scopes "Directory.Read.All"
        }
    }
    $GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
    $R = Invoke-GraphRequest -Method GET -Uri "/beta/servicePrincipals/$($GraphServicePrincipal.Id)/approles"
    if ($R -contains "@odata.nextLink") {
        $Approles = do {
            $R.Value
            $R = Invoke-GraphRequest -Method GET -Uri $($R."@odata.nextLink")
        } until ($R -notcontains "@odata.nextLink")
    }
    else {
        $Approles = $R.Value
    }
    if ($search) {
        $Approles | Where-Object { $_.value -match $search } | select-object @{label = "Id"; Expression = { $_["id"] } }, @{label = "Scope"; Expression = { $_["value"] } }, @{label = "Description"; Expression = { $_["displayName"] } } 
    }
    else {
        $Approles | Select-Object @{label = "Id"; Expression = { $_["id"] } }, @{label = "Scope"; Expression = { $_["value"] } }, @{label = "Description"; Expression = { $_["displayName"] } }
    }
}