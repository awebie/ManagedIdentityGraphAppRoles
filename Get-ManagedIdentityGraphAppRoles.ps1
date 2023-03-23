function Get-ManagedIdentityGraphAppRoles {
    <#
.SYNOPSIS
   Gets Microsoft Graph assigned scope permissions for a managed identity in Azure AD.
.DESCRIPTION
  The Set-ManagedIdentityGraphAppRoles function sets Microsoft Graph scope permissions for a managed identity in Azure AD. 

.PARAMETER ManagedIdentityId
  The ObjectID of the managed identity whose associated Microsoft Graph service principal scopes you want to query.

.EXAMPLE
    Get-ManagedIdentityGraphAppRoles -ManagedIdentityId "9832b904-de6c-44d6-9473-099b3f890cb4"
    This example retrieves a list of Microsoft Graph Scopes associated with the Managed Identity with ID "9832b904-de6c-44d6-9473-099b3f890cb4".

    .NOTES
    Author: Alec Weber
    Date: 03/13/2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ManagedIdentityId
    )
    Import-Module Microsoft.Graph.Authentication
    if ($Null -eq (Get-mgcontext)) {
        Connect-MgGraph -Scopes "Directory.Read.All"
    }
    else {
        if ((Get-Mgcontext).Scopes -notcontains "Directory.Read.All") {
            Connect-MgGraph -Scopes "Directory.Read.All"
        }
    } 
    try {
        $ManagedIdentityServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $ManagedIdentityId
    }
    catch {
        throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "The Managed Idenity could not be found: $($_.Message)"
    }
    $AllAppRoles = Get-GraphAppRoles
    $Assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ManagedIdentityServicePrincipal.Id 
    foreach ($Assignment in $Assignments) {
        $AllAppRoles | where-object { $_.Id -eq $Assignment.AppRoleId }
    }
}