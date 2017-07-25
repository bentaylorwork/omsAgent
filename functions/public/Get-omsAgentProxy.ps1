function Get-omsAgentProxy
{
	<#
		.SYNOPSIS 
			Gets OMS proxy details from remote computers
		.EXAMPLE
			Get-omsAgentProxy -computerName 'computer1', 'computer2'
		.NOTES
			Written by Ben Taylor
			Version 1.0, 06.03.2017
	#>
	[CmdletBinding()]
	[OutputType([System.Collections.ArrayList])]
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
				$psSession = New-PSSession -ComputerName $computer -EnableNetworkAccess @commonSessionParams

				Write-Verbose "[$(Get-Date -Format G)] - $computer - Trying to find workspace"
				Get-omsAgentProxyInternal -computerName $computer -session $psSession
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