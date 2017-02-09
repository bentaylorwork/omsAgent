$publicFunctions  = Get-ChildItem -Path $PSScriptRoot\functions\public\*.ps1 -ErrorAction SilentlyContinue
$privateFunctions = Get-ChildItem -Path $PSScriptRoot\functions\private\*.ps1 -ErrorAction SilentlyContinue

if($null -ne $publicFunctions)
{
	forEach($importFunction in ($publicFunctions + $privateFunctions))
	{
		try 
		{	
			. $importFunction
		}
		catch
		{
			Write-Error "ERROR: Failed to import function $($importFunction)"
		}
	}

	#Format Views
	$formatViews = Get-ChildItem -Path $PSScriptRoot\views\*format.ps1xml -ErrorAction SilentlyContinue

	foreach ($formatView in $formatViews)
	{
		Update-FormatData -PrependPath $formatView
	}
}
else
{
	Write-Error "ERROR: No public functions to load."
}