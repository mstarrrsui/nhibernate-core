param (
	[string]$prodnuspecFile = "./packaging/NHibernate.nuspec",
	[string]$devnuspecFile = "",
	[string]$serverUrl = "http://rsuinuget/NuGet",
	[switch]$nopush
 )
$VersionNumber="4.0.5.9999"
$baseDir = "."
$projdir = $baseDir + "/packaging"


$nuspecFile = $prodnuspecFile

 
$NUGET_EXE_SUCCESSFULLY_CREATED_PACKAGE_MESSAGE_REGEX = [regex] "(?i)(Successfully created package '(?<FilePath>.*?)'.)"
$API_KEY="6ce9f719-d5de-48bd-ade4-936074e39327"
 


$packCommand = "& nuget pack ""$nuspecFile"" -Version $VersionNumber"
$packCommand = $packCommand -ireplace ';', '`;'		# Escape any semicolons so they are not interpreted as the start of a new command.

# Create the package.
$packOutput = [string]::Empty	# Variable to hold the NuGet.exe output.
Write-Verbose "About to run Pack command '$packCommand'."
Invoke-Expression -Command $packCommand -OutVariable packOutput > $null

# Convert the output of the above command from an ArrayList of strings to a single string and write it to the Verbose stream.
$packOutput = $($packOutput -join [Environment]::NewLine)
Write-Verbose $packOutput
#nuget pack $nuspecFile -Version $VersionNumber




# Get the path the NuGet Package was created to, and write it to the output stream.
$match = $NUGET_EXE_SUCCESSFULLY_CREATED_PACKAGE_MESSAGE_REGEX.Match($packOutput)
if ($match.Success)
{
	$nuGetPackageFilePath = $match.Groups["FilePath"].Value
	
	# Have this cmdlet return the path that the new NuGet Package was created to.
	# This should be the only code that uses Write-Output, as it is the only thing that should be returned by the cmdlet.
	Write-Output $nuGetPackageFilePath
}


if ($noPush -eq $false)
{
	Write-Output "Pushing file[$nuGetPackageFilePath] to server url [$serverUrl]..."
	Write-Output "nuget push $nuGetPackageFilePath $API_KEY -s $serverUrl"
	nuget push $nuGetPackageFilePath $API_KEY -s $serverUrl
	Write-Output "Done."
}









