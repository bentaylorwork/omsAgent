function Get-omsAgentInternal
{
	[CmdletBinding()]
	[OutputType('omsAgent')]
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
			$oms = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.displayName -eq 'Microsoft Monitoring Agent' }

			if($oms)
			{
				$omsInfo = @{
						PSTypeName      = 'omsAgent'
						computerName    = $USING:computerName
						DisplayName     = $oms.DisplayName
						Version         = $oms.Version
						DisplayVersion  = $oms.DisplayVersion
						UninstallString = $oms.UninstallString
				}
				try
				{
					New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop | Out-Null

					$omsInfo.comObjectAvailable = $true
				}
				catch
				{
					$omsInfo.comObjectAvailable = $false
				}

				New-Object -TypeName PSObject -Property $omsInfo
			}
		} -ErrorAction Stop
	}
	catch
	{
		Throw $_
	}
}