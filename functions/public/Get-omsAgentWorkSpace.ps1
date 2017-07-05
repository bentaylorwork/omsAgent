function Get-omsAgentWorkSpace
{
	<#
		.SYNOPSIS 
			Gets OMS workspace details from remote computers
		.EXAMPLE
			Get-omsAgentWorkSpace -computerName 'computer1', 'computer2'
		.EXAMPLE
			Get-omsAgentWorkSpace -computerName 'computer1', 'computer2' -workSpaceId '<workSpaceId>'
		.NOTES
			Written by Ben Taylor
			Version 1.1, 08.02.2017
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
		$Credential,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]
		$workspaceid
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

		$omsSessionParams = @{}

		If ($PSBoundParameters['workspaceid'])
		{
			$omsSessionParams.workspaceid = $workspaceid
		}
	}
	Process
	{
		forEach($computer in $computerName)
		{
			try
			{
				Write-Verbose "[$(Get-Date -Format G)] - $computer - Creating Remote PS Session"
				$psSession = New-PSSession -ComputerName $computer @commonSessionParams -EnableNetworkAccess

				Write-Verbose "[$(Get-Date -Format G)] - $computer - Trying to find workspace"
				Get-omsAgentWorkSpaceInternal -computerName $computer -session $psSession @omsSessionParams
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