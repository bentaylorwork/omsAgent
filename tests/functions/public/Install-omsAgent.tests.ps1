if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
    Describe 'Install-omsAgent' {
        BeforeAll {
            Mock Invoke-Command {}
        }

        Context 'Logic' {
            it 'Parameters' {
                {Install-omsAgent -workspa 'test' -ErrorAction Stop -WhatIf:$false -Confirm:$false} | Should Throw
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentInternal { $null }

                Install-omsAgent -workspaceid '34434343' -workspacekey 'dfdfdf' -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}