#region Resource functions
function Set-File {
	[OutputType('void')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Content
	)

	Set-Content -Path $FilePath

}

function Get-File {
	[OutputType('string')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Server,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path
	)

	$sb = {
		if (-not (Test-Path -Path $using:Path -PathType Leaf)) {
			throw "The file [$($using:Path)] could not be found"
		}
		Get-Content -Path $using:Path -Raw
	}
	Invoke-Command -ComputerName $Server -ScriptBlock $sb
}

function Test-File {
	[OutputType('bool')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Content,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$ExpectedContent
	)

	if ($Content -ne $ExpectedContent) {
		$false
	} else {
		$true
	}
}
#endregion

#region Configuration functions
function Get-ExpectedConfiguration {
	[OutputType('pscustomobject')]
	[CmdletBinding()]
	param
	()

	[pscustomobject](Import-PowerShellDataFile -Path "$PSScriptRoot\ExpectedApplicationConfiguration.psd1")
}

function Get-ActualConfiguration {
	[OutputType('hashtable')]
	[CmdletBinding()]
	param
	()

	## Get the expected config to just get the template
	$config = Get-ExpectedConfiguration

	## Process the values in the template and overwrite expected with actual configuration
	$config.ServerTargets | foreach {
		$server = $_
		$_.ConfigurationItems | foreach {
			$resourceName = $configItem.Type
			$resourceParams = @{
				Server = $server.Name
				Path   = $_.Path
			}
			if ($result = & "Get-$resourceName" @resourceParams) {
				$_.Content = $result
			} else {
				$_.Content = 'Error'
			}
		}
	}
	$config
}

function Set-ExpectedConfiguration {
	[OutputType('void')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[hashtable]$Configuration
	)

	

	
}

function Compare-Configuration {
	[OutputType('hashtable')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[hashtable]$Configuration,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[hashtable]$ExpectedConfiguration = (Get-ExpectedConfiguration)
	)

	$diffOutput = @{}
	$ExpectedConfiguration.ServerTargets | foreach {
		$expectServerTarget = $_
		$actualServerTarget = $Configuration.ServerTargets | where { $_.Name -eq $expectServerTarget.Name }
		$expectServerTarget.ConfigurationItems | foreach {
			$expectConfigItem = $_
			$actualConfigItem = $expectServerTarget.ConfigurationItems | where { $_.Path -eq $actualConfigItem.Path }
			if ($expectConfigItem.Content -ne $actualConfigItem.Content) {
				$actualConfigItem
			}
		}
	}
}
#endregion