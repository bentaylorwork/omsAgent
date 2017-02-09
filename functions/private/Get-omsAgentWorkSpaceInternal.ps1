function Get-omsAgentWorkSpaceInternal
{
	[CmdletBinding()]
	[OutputType()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$computerName,
		[Parameter(Mandatory=$true)]
		[object]$session,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$workspaceid
	)

	try
	{
		Invoke-Command -Session $session -ScriptBlock {
			$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop

			if($USING:PSBoundParameters['workspaceid'])
			{
				$omsAgent = $omsObj.GetCloudWorkspace($USING:workspaceid)
			}
			else
			{
				$omsAgent = $omsObj.GetCloudWorkspaces()
			}

			$omsAgent | Add-Member -NotePropertyName 'computerName' -NotePropertyValue $USING:computerName

			$omsAgent
		} -ErrorAction Stop
	}
	catch
	{
		$null
	}
}