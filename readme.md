# Microsoft OMS Agent Management (Windows)

## Overview
A PowerShell module to aide with deployment and management of OMS agents on remote computers.

## Commands
* Add-omsAgentWorkSpace
* Get-omsAgent
* Get-omsAgentWorkSpace
* Install-omsAgent
* Remove-omsAgentWorkSpace
* Uninstall-omsAgent
* Update-omsAgentWorkSpace

## Examples
* Add-omsAgentWorkSpace
```PowerShell
Add-omsAgentWorkSpace -computerName 'computer1', 'computer2' -workSpaceId '<workSpace>' -workSpaceKey '<workSpaceKey>'

$workSpace = Get-Credential
Add-omsAgentWorkSpace -computerName 'computer1', 'computer2' -workSpace $workSpace
```

* Get-omsAgent
```PowerShell
Get-omsAgent -computerName 'computer1', 'computer2'
```

* Get-omsAgentWorkSpace
```PowerShell
Get-omsAgentWorkSpace -computerName 'computer1', 'computer2'

Get-omsAgentWorkSpace -computerName 'computer1', 'computer2' -workSpaceId '<workSpaceId>'
```

* Install-omsAgent
```PowerShell
$workSpace = Get-Credential
Install-OmsAgent -computerName 'computerOne' -workspace $workSpace -verbose

Install-OmsAgent -computerName <computerName> -workspaceID '<workSpaceID>' -workspaceKey '<workSpaceKey>' -Verbose

Install-OmsAgent -sourcePath 'c:\MMASetup-AMD64.exe' -workspaceID '<workSpaceID>' -workspaceKey '<workSpaceKey>' -Verbose
```

* Remove-omsAgentWorkSpace
```PowerShell
Remove-omsAgentWorkSpace -computerName 'computer1', 'computer2' -workspaceid '<workspaceid>'
```

* Uninstall-omsAgent
```PowerShell
Uninstall-OmsAgent -computerName 'computer1', 'computer2' -Verbose
```

* Update-omsAgentWorkSpace
```PowerShell
Update-omsAgwentWorkSpacekey -computerName 'computer1', 'computer2' -workspaceid '<workSpaceId>' -workspacekey '<workSpaceKey>'

$workSpace = Get-Credential
Update-omsAgwentWorkSpacekey -computerName 'computer1', 'computer2' -workSpace $workSpace
```

## Installation
The module is published to the PowerShell Gallery (<https://www.powershellgallery.com/packages/omsAgent>).

```PowerShell
Install-Module -Name omsAgent
```

## Versions
### 1.1
* Release adding the the following support:
    * Added Basic Tests.
    * Added support for using the WorkSpace ID and WorkSpace Key in the form of a PS Credential.

### 1.0
* Initial release with the following support:
    * Install\Un-Install Support.
    * Get support for workspaces\\install status.
    * Add\Remove\Update agents on remote computers.

## Limitations
* No 32 Bit agent support.
* No OMS Agent proxy support.

## Contributors
- Ben Taylor