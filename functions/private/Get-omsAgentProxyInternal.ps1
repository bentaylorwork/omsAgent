function Get-omsAgentProxyInternal
{
	[CmdletBinding()]
	[OutputType('omsAgentProxy')]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$computerName,
		[Parameter(Mandatory=$true)]
		[object]$session
	)

	try
	{
		Invoke-Command -Session $session -ScriptBlock {
			$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop

			if($omsObj.proxyURL)
			{
				$omsProxyInfo = @{
						PSTypeName    = 'omsAgentProxy'
						computerName  = $USING:computerName
						proxyURL      = $omsObj.proxyURL
						proxyUsername = $omsObj.proxyUserName
				}

				New-Object -TypeName PSObject -Property $omsProxyInfo
			}
		} -ErrorAction Stop -HideComputerName
	}
	catch
	{
		Throw $_
	}
}