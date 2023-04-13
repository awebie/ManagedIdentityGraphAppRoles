function Add-ManagedIdentityGraphAppRoles {
    <#
.SYNOPSIS
    adds Microsoft Graph scope permissions for a managed identity in Azure AD.
.DESCRIPTION
    The Add-ManagedIdentityGraphAppRoles function adds Microsoft Graph scope permissions for a managed identity in Azure AD.
.PARAMETER ManagedIdentityID
    The ID of the managed identity for which the Microsoft Graph scope permissions will be set.
.PARAMETER AppRole
    An array of scopes to be set for the managed identity. Each scope should be specified as a string that represents an Microsoft Graph AppRole scope.
.EXAMPLE
    add-ManagedIdentityGraphAppRoles -ManagedIdentityID "9832b904-de6c-44d6-9473-099b3f890cb4" -AppRole "Directory.Read.All", "Device.ReadWrite.All"
    This example adds the AppRoles "Directory.Read.All" and "Device.ReadWrite.All" for the managed identity with the ID "9832b904-de6c-44d6-9473-099b3f890cb4".
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
    $AllRoles = Get-GraphAppRoles
    $DesiredRoles = $AllRoles | Where-Object { $_.Scope -in $AppRole}
        if (([Array]($DesiredRoles)).Count -ne $AppRole.Count ) {
            throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "One or more of the desired scopes were not found: $($AppRole|Where-Object {$_ -notin $AllRoles.Scope})"
        }
        Foreach ($DesiredRoleId in $DesiredRoles.Id) {
        New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $GraphServicePrincipal.Id  -BodyParameter @{
            "principalId" = "$($ManagedIdentityServicePrincipal.Id)" 
            "resourceId" = "$($GraphServicePrincipal.Id)"
            "appRoleId" = "$($DesiredRoleId)"
        }
    }
}
