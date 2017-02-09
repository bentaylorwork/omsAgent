InModuleScope -moduleName omsAgent {
    Describe 'Get-omsAgentWorkSpace' {
        Context 'Logic' {
            it 'Parameters' {
                {Get-omsAgentWorkSpace -ErrorAction Stop} | Should Not Throw
                {Get-omsAgentWorkSpace -compName -ErrorAction Stop} | Should Throw
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentWorkSpaceInternal { $null }

                Get-omsAgentWorkSpace -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}