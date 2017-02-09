InModuleScope -moduleName omsAgent {
    Describe 'Get-omsAgent' {
        Context 'Logic' {
            it 'Parameters' {
                {Get-omsAgent -ErrorAction Stop} | Should Not Throw
                {Get-omsAgent -compName -ErrorAction Stop} | Should Throw
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsAgentInternal { $null }

                Get-omsAgent -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}