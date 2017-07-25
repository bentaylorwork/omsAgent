#Requires -Version 5.0

function Install-OmsDependencyAgent
{
	<#
		.Synopsis
			Installs the OMS Dependency Agent on remote computers.
		.DESCRIPTION
			Either downloads the installer from a URL or copies the installer via the powershell session.
		.EXAMPLE
			Install-OmsDependencyAgent -sourcePath 'c:\MMASetup-AMD64.exe' -Verbose
		.NOTES
			Written by Ben Taylor
			Version 1.0, 22.06.2017
	#>
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low', DefaultParameterSetName='downloadOMS')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $false, Position = 0, ValueFromPipeline=$True, valuefrompipelinebypropertyname=$true)]
		[ValidateNotNullOrEmpty()]
		[Alias('IPAddress', 'Name')]
		[string[]]
		$computerName = $env:COMPUTERNAME,
		[Parameter(ParameterSetName='downloadOMS')]
		[ValidateNotNullOrEmpty()]
		[string]
		$downloadURL = 'https://aka.ms/Dependencyagentwindows',
		[Parameter(ParameterSetName='localOMS')]
		[ValidateScript({Test-Path $_ })]
		[string]
		$sourcePath,
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
		forEach ($computer in $computerName)
		{
			try
			{
				Write-Verbose "[$(Get-Date -Format G)] - $computer - Creating Remote PS Session"
				$psSession = New-PSSession -ComputerName $computer -EnableNetworkAccess @commonSessionParams

				Write-Verbose "[$(Get-Date -Format G)] - $computer - Checking if OMS is Installed"
					
				if(Get-omsAgentInternal -computerName $computer -session $psSession)
				{
					If ($Pscmdlet.ShouldProcess($computer, 'Install OMS Dependency Agent'))
					{
						 $path = Invoke-Command -Session $pssession -ScriptBlock {
							$path = Join-Path $ENV:temp "DependencyAgent.exe"

							# Check if file exists and if so remove
							if(Test-Path $path)
							{
								Remove-Item $path -force -Confirm:$false
							}

							$path
						 }

						if($PSBoundParameters.sourcePath -eq $true)
						{
							Write-Verbose "[$(Get-Date -Format G)] - $computer - Copying files over powershell session"
							Copy-Item -Path $sourcePath -Destination (Split-path $path) -ToSession $psSession -Force
						}
						else
						{
							Write-Verbose "[$(Get-Date -Format G)] - $computer - Trying to download installer from URL - $downloadURL"
							Invoke-Command -Session $psSession -ScriptBlock {
								Invoke-WebRequest $USING:downloadURL -OutFile $USING:path -ErrorAction Stop | Out-Null
							} -ErrorAction Stop
						}


						Write-Verbose "$computer - Trying to install OMS..."
						$installString = $path + ' /S'

						$installSuccess = Invoke-Command -Session $psSession -ScriptBlock {
							cmd.exe /C $USING:installString
							$LASTEXITCODE
						} -ErrorAction Stop

						if($installSuccess -ne 0)
						{
							Write-Error "$computer - OMS didn't install correctly based on the exit code"
						}
						else
						{
							if(Get-omsAgentInternal -computerName $computer -session $psSession)
							{
								Write-Verbose "[$(Get-Date -Format G)] - $computer - OMS Dependency Agent installed correctly"
							}
							else
							{
								Write-Error "[$(Get-Date -Format G)] - $computer - OMS Dependency Agent didn't install correctly based on the exit code"
							}
						}
					}
				}
				else
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - OMS Agent not installed so skipping."
				}
			}
			catch
			{
				Write-Error $_
			}
			Finally
			{
				Write-Verbose "[$(Get-Date -Format G)] - $computer - Tidying up install files\sessions if needed"

				if($null -ne $psSession)
				{
					try
					{
						Invoke-Command -Session $pssession -ScriptBlock {
							if(Test-Path $USING:path)
							{
								Remove-Item $USING:path -force -Confirm:$false
							}
						} -ErrorAction Stop
					}
					catch
					{
						Write-Verbose "[$(Get-Date -Format G)] - $computer - Nothing to tidy up"
					}

					Remove-PSSession $psSession -whatif:$false -Confirm:$false
				}
			}
		}
	}
}