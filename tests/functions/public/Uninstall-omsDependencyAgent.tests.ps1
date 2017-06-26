if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
    Describe 'Uninstall-omsDependencyAgent' {
        BeforeAll {
            Mock Invoke-Command {}
        }

        Context 'Logic' {
            it 'Parameters' {
                {Uninstall-omsDependencyAgent -workspa 'test' -ErrorAction Stop -WhatIf:$false -Confirm:$false} | Should Throw
            }

            it 'Agent Is Installed' {
                Mock Get-omsDependencyAgentInternal { $true }

                Uninstall-omsDependencyAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 1 -Scope It
            }

            it 'Agent Is Not Installed' {
                Mock Get-omsDependencyAgentInternal { $false }

                Uninstall-omsDependencyAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 0 -Scope It     
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsDependencyAgentInternal { $null }

                Uninstall-omsDependencyAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}