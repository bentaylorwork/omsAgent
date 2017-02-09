# Microsoft OMS Agent Management (Windows)

## Overview
A PowerShell module to aide with deployment and management of OMS agents on remote computers.

## Requirements
- OMS Agent COM Object available on the computers to manage.

## Commands
* Add-omsAgentWorkSpace
* Get-omsAgent
* Get-omsAgentWorkSpace
* Install-omsAgent
* Remove-omsAgentWorkSpace
* Uninstall-omsAgent
* Update-omsAgentWorkSpace

## Examples

```PowerShell
# Example - Add-omsAgentWorkSpace
Add-omsAgentWorkSpace

# Example - Get-omsAgent
Get-omsAgent

# Example - Get-omsAgentWorkSpace
Get-omsAgentWorkSpace

# Example - Install-omsAgent
Install-omsAgent

# Example - Remove-omsAgentWorkSpace
Remove-omsAgentWorkSpace

# Example - Uninstall-omsAgent
Uninstall-omsAgent

# Example - Update-omsAgentWorkSpace
Update-omsAgentWorkSpace
```

## Versions
### 1.1
* Initial release with the following support:
    * Added Basic Tests.
    * Added support for using the WorkSpace Key in the form of a PS Credential.

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