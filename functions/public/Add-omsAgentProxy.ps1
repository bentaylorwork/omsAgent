function Add-omsAgentProxy
{
	<#
		.SYNOPSIS 
			Adds a OMS Agent Proxy to remote computers.
		.EXAMPLE
			Add-omsAgentProxy -computerName 'computer1', 'computer2' -proxyURL 'proxy.local:443'
		.EXAMPLE
			$proxyCredential = Get-Credential
			Add-omsAgentProxy -computerName 'computer1', 'computer2' -proxyURL 'proxy.local:443' -proxyCredential $proxyCredential
		.NOTES
			Written by Ben Taylor
			Version 1.0, 06.03.2017
	#>
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
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
		$Credential,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$proxyURL,
		[Parameter(Mandatory=$false)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$proxyCredential
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

		If ($PSBoundParameters['proxyCredential'])
		{
			$proxyUserName = (Convert-CredentialToPlainText -credential $proxyCredential).userName
			$proxyPassword = (Convert-CredentialToPlainText -credential $proxyCredential).passWord
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

				If(-not(Get-omsAgentProxyInternal -computerName $computer -session $psSession))
				{
					If ($Pscmdlet.ShouldProcess($computer, 'Add OMS Agent Proxy'))
					{
						Write-Verbose "[$(Get-Date -Format G)] - $computer - Adding OMS Agent Proxy"

						Invoke-Command -Session $psSession -ScriptBlock {
							$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop

							$omsObj.setProxyUrl($USING:proxyURL)
						} -ErrorAction Stop

						If ($PSBoundParameters['proxyCredential'])
						{
							Invoke-Command -Session $psSession -ScriptBlock {
								$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop

								$omsObj.SetProxyCredentials($USING:proxyUserName, $USING:proxyPassword)
							} -ErrorAction Stop
						}

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
					Write-Error "[$(Get-Date -Format G)] - $computer - OMS Proxy all ready found"
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