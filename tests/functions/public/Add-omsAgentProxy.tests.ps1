if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
	Describe 'Add-omsAgentProxy' {
		BeforeAll {
			Mock Invoke-Command {}
		}

		Context 'Logic' {
			Mock Get-omsAgentWorkSpaceInternal { $null }

			it 'Parameters' {
				{Add-omsAgentProxy -proxyUrl test.local -ErrorAction Stop} | Should Not Throw
				{Add-omsAgentProxy -workspa 'test' -workssey 'test' -ErrorAction Stop} | Should Throw
			}

			it 'Proxy Does Not Exist' {
				Mock Get-omsAgentProxyInternal { $null }

				Add-omsAgentProxy -proxyUrl test.local -ErrorAction SilentlyContinue | Out-Null

				Assert-MockCalled Invoke-Command -Exactly 1 -Scope It
			}

			it 'Proxy Does Exists' {
				Mock Get-omsAgentProxyInternal { $true }

				Add-omsAgentProxy -proxyUrl test.proxy -ErrorAction SilentlyContinue | Out-Null

				Assert-MockCalled Invoke-Command -Exactly 0 -Scope It     
			}

			it 'Creates\Removes A PsSession' {
				Mock New-PSSession { 'sessionData' }
				Mock Remove-PSSession {}
				Mock Get-omsAgentProxyInternal { $null }

				Add-omsAgentProxy -proxyUrl test.local -ErrorAction SilentlyContinue | Out-Null

				Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
				Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
			}
		}
	}
}