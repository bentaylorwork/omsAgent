InModuleScope -moduleName omsAgent {
    Describe 'Add-omsAgentWorkSpace' {
        BeforeAll {
            Mock Invoke-Command {}
        }

        Context 'Logic' {
            it 'Parameters' {
                {Add-omsAgentWorkSpace -workspaceid 'test' -workspacekey 'test' -ErrorAction Stop} | Should Not Throw
                {Add-omsAgentWorkSpace -workspa 'test' -workssey 'test' -ErrorAction Stop} | Should Throw
            }

            it 'WorkSpace Does Not Exist' {
                Mock Get-omsAgentWorkSpaceInternal { $null }

                Add-omsAgentWorkSpace -workspaceid 'test' -workspacekey 'test' -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 1 -Scope It
            }

            it 'WorkSpace Does Exists' {
                Mock Get-omsAgentWorkSpaceInternal { $true }

                Add-omsAgentWorkSpace -workspaceid 'test' -workspacekey 'test' -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled Invoke-Command -Exactly 0 -Scope It     
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentWorkSpaceInternal { $null }

                Add-omsAgentWorkSpace -workspaceid 'test' -workspacekey 'test' -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}