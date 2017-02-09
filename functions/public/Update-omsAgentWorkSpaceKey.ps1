function Update-omsAgentWorkSpaceKey
{
	<#
		.SYNOPSIS 
			Updates the OMS workspace key on remote computers.
		.EXAMPLE
			Update-omsAgwentWorkSpacekey -computerName 'computer1', 'computer2' -workspaceid '<workSpaceId>' -workspacekey '<workSpaceKey>'
		.EXAMPLE
			$workSpace = Get-Credential
			Update-omsAgwentWorkSpacekey -computerName 'computer1', 'computer2' -workSpace $workSpace
		.NOTES
			Written by Ben Taylor
			Version 1.1, 09.01.2017
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
		[Parameter(Mandatory=$true, ParameterSetName='workSpaceClearText')]
		[ValidateNotNullOrEmpty()]
		[string]
		$workspaceid,
		[Parameter(Mandatory=$true, ParameterSetName='workSpaceClearText')]
		[ValidateNotNullOrEmpty()]
		[string]
		$workspacekey,
		[Parameter(Mandatory=$true, ParameterSetName='workSpaceEncrypt')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$workSpace
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

		If ($PSBoundParameters['workspace'])
		{
			$workspaceid  = (Convert-CredentialToPlainText -credential $workSpace).userName
			$workspacekey = (Convert-CredentialToPlainText -credential $workSpace).passWord
		}

		$omsSessionParams = @{
			workspaceid = $workspaceid
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

				If(Get-omsAgentWorkSpaceInternal -computerName $computer -session $psSession @omsSessionParams)
				{
					If ($Pscmdlet.ShouldProcess($computer, 'Update OMS Work Space Key'))
					{
						Write-Verbose "[$(Get-Date -Format G)] - $computer - Updating OMS Workspace"

						Invoke-Command -Session $psSession -ScriptBlock {
							$omsObj = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop
							$omsObj.GetCloudWorkspace($USING:workspaceId).updateWorkSpaceKey($USING:workspaceKey)
							$omsObj.ReloadConfiguration()
						} -ErrorAction Stop
					}
				}
				else
				{
					Write-Error "[$(Get-Date -Format G)] - $computer - No OMS workspace with that ID could be found to update"
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