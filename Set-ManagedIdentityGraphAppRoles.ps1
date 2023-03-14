function Set-ManagedIdentityGraphAppRoles {
    <#
.SYNOPSIS
    Sets Microsoft Graph scope permissions for a managed identity in Azure AD.
.DESCRIPTION
    The Set-ManagedIdentityGraphAppRoles function sets Microsoft Graph scope permissions for a managed identity in Azure AD.
.PARAMETER ManagedIdentityID
    The ID of the managed identity for which the Microsoft Graph scope permissions will be set.
.PARAMETER AppRole
    An array of scopes to be set for the managed identity. Each scope should be specified as a string that represents an Microsoft Graph AppRole scope.
.EXAMPLE
    Set-ManagedIdentityGraphAppRoles -ManagedIdentityID "9832b904-de6c-44d6-9473-099b3f890cb4" -AppRole "Directory.Read.All", "Device.ReadWrite.All"
    This example sets the AppRoles "Directory.Read.All" and "Device.ReadWrite.All" for the managed identity with the ID "9832b904-de6c-44d6-9473-099b3f890cb4".
.INPUTS
    None.
.OUTPUTS
    None.
.NOTES
  Author: Alec Weber
  Date: 03/13/2023
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ManagedIdentityId,
        [Parameter(Mandatory = $true)]
        [string[]]
        $AppRole
    )
    Import-Module Microsoft.Graph.Authentication
    if ($Null -eq (Get-mgcontext)) {
        Connect-MgGraph -Scopes "Directory.ReadWrite.All","ServicePrincipalEndpoint.ReadWrite.All","AppRoleAssignment.ReadWrite.All"
    }
    else {
        if ((Get-Mgcontext).Scopes -notcontains "Directory.ReadWrite.All","ServicePrincipalEndpoint.ReadWrite.All","AppRoleAssignment.ReadWrite.All") {
            Connect-MgGraph -Scopes "Directory.ReadWrite.All","ServicePrincipalEndpoint.ReadWrite.All","AppRoleAssignment.ReadWrite.All"
        }
    } 
    try {
        $ManagedIdentityServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $ManagedIdentityId
    }
    catch {
        throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "The Managed Idenity could not be found: $($_.Message)"
    }
    $GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
    $allRoles = Get-GraphAppRoles
    Foreach ($Role in $AppRole) {
        $desiredRole = $allRoles | Where-Object { $_.Scope -eq $Role }
        if (($Null -eq $desiredRole ) -or ($desiredRole -is [Array])) {

            throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "The desired AppRole was not found"
        }
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ManagedIdentityServicePrincipal.Id -ResourceId $GraphServicePrincipal.Id -AppRoleId $desiredRole.Id
    }
}