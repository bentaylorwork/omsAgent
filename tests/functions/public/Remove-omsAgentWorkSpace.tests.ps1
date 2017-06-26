if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
    Describe 'Remove-omsAgentWorkSpace' {
        BeforeAll {
            Mock Invoke-Command {}
        }

        Context 'Logic' {
            it 'Parameters' {
                {Remove-omsAgentWorkSpace -workspa 'test' -ErrorAction Stop -WhatIf:$false -Confirm:$false} | Should Throw
            }

            it 'WorkSpace Does Not Exist' {
                Mock Get-omsAgentWorkSpaceInternal { $null }

                Remove-omsAgentWorkSpace -workspaceid 'test' -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 0 -Scope It
            }

            it 'One Workspace - WorkSpace Does Exists' {
                $script:i = 1

                Mock Get-omsAgentWorkSpaceInternal {
                    if ($script:i -ge 2)
                    {
                        $null
                    }
                    else
                    {
                        $true
                    }

                    $script:i++
                }

                Remove-omsAgentWorkSpace -workspaceid 'test' -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 1 -Scope It     
            }

            it 'Two Workspaces - WorkSpace Does Exists' {
                Mock Get-omsAgentWorkSpaceInternal { $true }

                Remove-omsAgentWorkSpace -workspaceid 'test' -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 2 -Scope It     
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentWorkSpaceInternal { $null }

                Remove-omsAgentWorkSpace -workspaceid 'test' -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}