InModuleScope -moduleName omsAgent {
    Describe 'Get-omsDependencyAgent' {
        Context 'Logic' {
            it 'Parameters' {
                {Get-omsDependencyAgent -ErrorAction Stop} | Should Not Throw
                {Get-omsDependencyAgent -compName -ErrorAction Stop} | Should Throw
            }

            it 'Creates\Removes A PsSession' {
                Mock New-PSSession { 'sessionData' }
                Mock Remove-PSSession {}
                Mock Get-omsDependencyAgentInternal { $null }

                Get-omsDependencyAgent -ErrorAction SilentlyContinue | Out-Null

                Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
                Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
            }
        }
    }
}