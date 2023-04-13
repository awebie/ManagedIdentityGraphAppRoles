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
  Replaces any existing scopes
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

    Assert-RequiredScopes -RequiredScopes "Directory.Read.ALL", "ServicePrincipalEndpoint.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"
    try {
        $ManagedIdentityServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $ManagedIdentityId
    }
    catch {
        throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "The Managed Idenity could not be found: $($_.Message)"
    }
    $GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
    $AllRoles = Get-GraphAppRoles
    $Assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ManagedIdentityServicePrincipal.Id
    $DesiredRoles = $AllRoles | Where-Object { $_.Scope -in $AppRole}
        if (([Array]($DesiredRoles)).Count -ne $AppRole.Count ) {
            throw New-Object -typename System.Management.Automation.ItemNotFoundException -ArgumentList "One or more of the desired scopes were not found: $($AppRole|Where-Object {$_ -notin $AllRoles.Scope})"
        }
    $Assignments|Where-Object {$_.AppRoleId -notin $DesiredRoles.Id} |ForEach-Object {
        Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ManagedIdentityServicePrincipal.Id -AppRoleAssignmentId $_.Id
    }
        $RolesToAssign = $DesiredRoles |Where-Object {$_.Id -notin $Assignments.AppRoleId}
        Foreach ($RoleToAssignId in $RolesToAssign.Id) {
        New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $GraphServicePrincipal.Id  -BodyParameter @{
            "principalId" = "$($ManagedIdentityServicePrincipal.Id)" 
            "resourceId" = "$($GraphServicePrincipal.Id)"
            "appRoleId" = "$($RoleToAssignId)"
        }
    }
}
