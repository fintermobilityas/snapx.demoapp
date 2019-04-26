param(
	[Parameter(Position = 0, ValueFromPipeline = $true)]
	[string] $Version = "1",
	[Parameter(Position = 1, ValueFromPipeline = $true)]
	[ValidateSet("netcoreapp2.2")]
	[string] $NetCoreAppVersion = "netcoreapp2.2"
)

$OSPlatform = $null
$OSVersion = [Environment]::OSVersion

$Version = "$Version.0.0"
$WorkingDir = Split-Path -parent $MyInvocation.MyCommand.Definition
$BuildDir = Join-Path $WorkingDir snapx/artifacts/demoapp
$BuildWindowsDir = Join-Path $BuildDir win-x64/$Version
$BuildLinuxDir = Join-Path $BuildDir linux-x64/$Version
$AssetsDir = Join-Path $WorkingDir snapx/assets
$IconsDir = Join-Path $AssetsDir icons

switch -regex ($OSVersion) {
    "^Microsoft Windows" {
		$OSPlatform = "Windows"
	}
}

. dotnet clean ./src/demoapp

# Windows
. dotnet publish --self-contained -r win-x64 -o $BuildWindowsDir /p:Version=$Version ./src/demoapp/demoapp.csproj -f $NetCoreAppVersion

if($OSPlatform -eq "Windows") {
	. snapx rcedit --gui-app -f $BuildWindowsDir/demoapp.exe --icon $IconsDir/demoapp.ico
}

# Linux
. dotnet publish --self-contained -r linux-x64 -o $BuildLinuxDir /p:Version=$Version ./src/demoapp/demoapp.csproj -f $NetCoreAppVersion

