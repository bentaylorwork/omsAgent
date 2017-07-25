if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
	Describe 'Remove-omsAgentProxy' {
		BeforeAll {
			Mock Invoke-Command {}
		}

		Context 'Logic' {
			it 'Parameters' {
				{Remove-omsAgentProxy -comt -ErrorAction Stop -WhatIf:$false -Confirm:$false} | Should Throw
			}

			it 'Proxy Does Not Exist' {
				Mock Get-omsAgentProxyInternal { $null }

				Remove-omsAgentProxy -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

				Assert-MockCalled Invoke-Command -Exactly 0 -Scope It
			}

			it 'Proxy Does Exists - No Workspaces' {
				Mock Get-omsAgentProxyInternal { $true }
				Mock Get-omsAgentWorkSpaceInternal { $null }

				Remove-omsAgentProxy -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

				Assert-MockCalled Invoke-Command -Exactly 1 -Scope It     
			}

			it 'Proxy Does Exists - Workspace Exists' {
				Mock Get-omsAgentProxyInternal { $true }
				Mock Get-omsAgentWorkSpaceInternal { $true }

				Remove-omsAgentProxy -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

				Assert-MockCalled Invoke-Command -Exactly 2 -Scope It     
			}

			it 'Creates\Removes A PsSession' {
				Mock New-PSSession { 'sessionData' }
				Mock Remove-PSSession {}
				Mock Get-omsAgentProxyInternal { $null }

				Remove-omsAgentProxy -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

				Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
				Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
			}
		}
	}
}