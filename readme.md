# ManagedIdentityGraphAppRoles

ManagedIdentityGraphAppRoles is a PowerShell module that simplifies the management of Microsoft Graph permissions on Azure Managed Identities. This module enables users to easily assign and remove app roles for Managed Identities, reducing the complexity of managing access to Microsoft Graph resources.

⚠ This module is under active development and isn't fully tested yet.

## Features

- Get available Microsoft Graph app roles 
- List app roles assigned to a Managed Identity
- Assign Microsoft Graph app roles to Managed Identities
- Remove Microsoft Graph app roles from Managed Identities

## Installation

To install ManagedIdentityGraphAppRoles from the PowerShell Gallery, run the following command:

```powershell
Install-Module -Name ManagedIdentityGraphAppRoles
```

## Usage

After installing the module, you can import it into your PowerShell session:

```powershell
Import-Module ManagedIdentityGraphAppRoles
```

### Get-GraphAppRoles

Get a list of Permission Scopes or "AppRoles" for Microsoft Graph.

To Get all Roles

```powershell
Get-GraphAppRoles
```
To Search a Specific Role

```powershell
Get-GraphAppRoles -Search "Role"
```

### Get-ManagedIdentityGraphAppRoles

Get the Microsoft Graph assigned scope permissions for a managed identity in Azure AD.

```powershell
Get-ManagedIdentityGraphAppRoles -ManagedIdentityId "9832b904-de6c-44d6-9473-099b3f890cb4"
```

### Remove-ManagedIdentityGraphAppRoles

Remove Microsoft Graph assigned scope permissions for a managed identity in Azure AD.

```powershell
Remove-ManagedIdentityGraphAppRoles -ManagedIdentityID "9832b904-de6c-44d6-9473-099b3f890cb4" -AppRole "Directory.Read.All", "Device.ReadWrite.All"
```

### Set-ManagedIdentityGraphAppRoles

Set (Replace) Microsoft Graph assigned scope permissions for a managed identity in Azure AD.

```powershell
Set-ManagedIdentityGraphAppRoles -ManagedIdentityID "9832b904-de6c-44d6-9473-099b3f890cb4" -AppRole "Directory.Read.All", "Device.ReadWrite.All"
```


### Add-ManagedIdentityGraphAppRoles

Add Microsoft Graph assigned scope permissions for a managed identity in Azure AD.

```powershell
Add-ManagedIdentityGraphAppRoles -ManagedIdentityID "9832b904-de6c-44d6-9473-099b3f890cb4" -AppRole "Directory.Read.All", "Device.ReadWrite.All"
```