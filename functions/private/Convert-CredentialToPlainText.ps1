function Convert-CredentialToPlainText
{
	<#
		.SYNOPSIS 
			Converts a credential to a plain text username and password.
		.NOTES
			Written by Ben Taylor
			Version 1.0, 05.01.2017
	#>
	[CmdletBinding()]
	[OutputType('System.Collections.Hashtable')]
	param (
		[Parameter(Mandatory=$true)]
		[pscredential]
		[System.Management.Automation.Credential()]
		$credential
	)

	@{
		userName = $credential.UserName
		passWord = $credential.GetNetworkCredential().Password
	}
}