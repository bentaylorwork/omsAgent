function Remove-omsAgentProxy
{
	<#
		.SYNOPSIS 
			Removes OMS Proxy to remote computers
		.EXAMPLE
			Remove-omsAgentProxy -computerName 'computer1', 'computer2'
		.NOTES
			Written by Ben Taylor
			Version 1.0, 06.03.2017
	#>
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
	[OutputType()]
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

				If(Get-omsAgentProxyInternal -computerName $computer -session $psSession)
				{
					If ($Pscmdlet.ShouldProcess($computer, 'Remove OMS Proxy'))
					{
						Write-Verbose "[$(Get-Date -Format G)] - $computer - Removing OMS Proxy"
						Invoke-Command -Session $psSession -ScriptBlock {
							$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop
							$omsObj.SetProxyInfo('', '', '')
						} -ErrorAction Stop

						if(Get-omsAgentWorkSpaceInternal -computerName $computer -session $psSession)
						{
							Invoke-Command -Session $psSession -ScriptBlock {
								$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop
								$omsObj.ReloadConfiguration()
							} -ErrorAction Stop
						}
					}
				}
				else
				{
					Write-Error "[$(Get-Date -Format G)] - $computer - No proxy could be found to remove."
				}
			}
			catch
			{
				Write-Error $_
			}
			finally
			{
				if($null -ne $psSession)
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - Closing Remote PS Session"
					Remove-PSSession $psSession -WhatIf:$false -Confirm:$false
				}
			}
		}
	}
}