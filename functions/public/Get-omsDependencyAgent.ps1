function Get-omsDependencyAgent
{
	<#
		.SYNOPSIS 
			Gets OMS Dependency Agent details from remote computers
		.EXAMPLE
			Get-omsDependencyAgent -computerName 'computer1', 'computer2'
		.NOTES
			Written by Ben Taylor
			Version 1.0, 22.06.2017
	#>
	[CmdletBinding()]
	[OutputType('omsAgent')]
	param (
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
		[ValidateNotNullOrEmpty()]
		[Alias('IPAddress', 'Name')]
		[string[]]
		$computerName = $env:COMPUTERNAME,
		[Parameter()]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential
	)

	Begin
	{
		$commonSessionParams = @{
			ErrorAction = 'Stop'
		}
		
		If ($PSBoundParameters['Credential'])
		{
			$commonSessionParams.Credential = $Credential
		}
	}
	Process
	{
		forEach($computer in $computerName)
		{
			try
			{
				Write-Verbose "[$(Get-Date -Format G)] - $computer - Creating Remote PS Session"
				$psSession = New-PSSession -ComputerName $computer @commonSessionParams

				Write-Verbose "[$(Get-Date -Format G)] - $computer - Trying to find Agent Version"
				Get-omsDependencyAgentInternal -computerName $computer -session $psSession
			}
			catch
			{
				Write-Error "[$(Get-Date -Format G)] - $computer - $_"
			}
			finally
			{
				if($null -ne $psSession)
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - Closing Remote PS Session"
					Remove-PSSession $psSession
				}
			}
		}
	}
}