InModuleScope -moduleName omsAgent {
    Describe 'Uninstall-omsAgent' {
        BeforeAll {
            Mock Invoke-Command {}
        }

        Context 'Logic' {
            it 'Parameters' {
                {Uninstall-omsAgent -workspa 'test' -ErrorAction Stop -WhatIf:$false -Confirm:$false} | Should Throw
            }

            it 'Agent Is Installed' {
                Mock Get-omsAgentInternal { $true }

                Uninstall-omsAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 1 -Scope It
            }

            it 'Agent Is Not Installed' {
                Mock Get-omsAgentInternal { $false }

                Uninstall-omsAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 0 -Scope It     
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentInternal { $null }

                Uninstall-omsAgent -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}