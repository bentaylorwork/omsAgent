if(-not (Get-Module omsAgent))
{
	$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\functions\public', '')
	Import-Module (Join-Path $here 'omsAgent.psd1') 
}

InModuleScope -moduleName omsAgent {
	Describe 'Get-omsAgentProxy' {
		Context 'Logic' {
			it 'Parameters' {
				{Get-omsAgentProxy -ErrorAction Stop} | Should Not Throw
				{Get-omsAgentProxy -compName -ErrorAction Stop} | Should Throw
			}

			it 'Creates\Removes A PsSession' {
				Mock New-PSSession { 'sessionData' }
				Mock Remove-PSSession {}

				Get-omsAgentProxy -ErrorAction SilentlyContinue | Out-Null

				Assert-MockCalled New-PSSession -Exactly 1 -Scope It  
				Assert-MockCalled Remove-PSSession -Exactly 1 -Scope It  
			}
		}
	}
}