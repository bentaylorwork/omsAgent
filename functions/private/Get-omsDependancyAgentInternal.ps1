function Get-omsDependencyAgentInternal
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
			$oms = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DependencyAgent\ -ErrorAction SilentlyContinue | Where-Object { $_.displayName -eq 'Dependency Agent' }

			if($oms)
			{
				$omsInfo = @{
						PSTypeName      = 'omsDependencyAgent'
						computerName    = $USING:computerName
						DisplayName     = $oms.DisplayName
						DisplayVersion  = $oms.DisplayVersion
						UninstallString = $oms.UninstallString
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