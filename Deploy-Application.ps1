param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('Foo')]
	[string]$Application
)

$expectedConfig = Get-ExpectedConfiguration -Provider 'JSON' -FilePath "$PSScriptRoot\ApplicationConfiguration.json"
if (-not (Test-ExpectedConfiguration -Configuration))

