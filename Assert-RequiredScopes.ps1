function Assert-RequiredScopes {
    <#
.SYNOPSIS
    Ensures the required Microsoft Graph API scopes are present in the current context.

.DESCRIPTION
    The Assert-RequiredScopes function checks if the specified Microsoft Graph API scopes are present in the current context.
    If any required scopes are missing, it connects to the Microsoft Graph API with the specified required scopes.

.PARAMETER RequiredScopes
    An array of required Microsoft Graph API scopes as strings.

.EXAMPLE
    Assert-RequiredScopes -RequiredScopes "Directory.ReadWrite.All", "ServicePrincipalEndpoint.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"
    This example ensures the current context has the "Directory.ReadWrite.All", "ServicePrincipalEndpoint.ReadWrite.All", and "AppRoleAssignment.ReadWrite.All" scopes.
    If any of the required scopes are missing, it connects to the Microsoft Graph API with those scopes.

.INPUTS
    None.

.OUTPUTS
    None.

.NOTES
    Author: Alec Weber
    Date:   03/16/2023
#>
        param (
            [Parameter(Mandatory = $true)]
            [string[]]
            $RequiredScopes
        )

        $currentScopes = (Get-Mgcontext).Scopes
        $missingScopes = $RequiredScopes | Where-Object { $_ -notin $currentScopes }

        if ($missingScopes) {
            Connect-MgGraph -Scopes $RequiredScopes
        }
}
