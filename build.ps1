param(
    
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string] $Version = "0.0.0",
    [Parameter(Position = 1, ValueFromPipeline = $true)]
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Release",
    [Parameter(Position = 2, ValueFromPipeline = $true)]
    [string] $SnapxToken = $null
)

$WorkingDirectory = Split-Path -parent $MyInvocation.MyCommand.Definition
. $WorkingDirectory\common.ps1

$Framework = "netcoreapp3.1"
$OSPlatform = $null
$Rid = $null
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

switch -regex ([Environment]::OSVersion) {
    "^Microsoft Windows" {
        $OSPlatform = "Windows"
        $Rid = "win-x64"
    }
    "^Unix" {
        $OSPlatform = "Unix"
        $Rid = "linux-64"   
    }	
    default {
        Write-Error "Unsupported os: $OSVersion"
    }
}

$BuildOutputDirectory = Join-Path $WorkingDirectory .snapx\artifacts\demoapp\$Rid\$Version
$SnapxYmlFilenamePath = Join-Path $WorkingDirectory .snapx\snapx.yml

Resolve-Shell-Dependency dotnet

Invoke-Command-Colored dotnet @(
    ("publish {0}" -f (Join-Path $WorkingDirectory Demoapp.sln))
    "/p:Version=$Version"
    "--runtime $Rid"
    "--self-contained"
    "--framework $Framework"
    "--output $BuildOutputDirectory"
    "--configuration $Configuration"
)

if([string]::IsNullOrWhiteSpace($SnapxToken) -eq $false) {
    $SnapxYmlContent = (Get-Content $SnapxYmlFilenamePath) -replace "token:.*", "token: ${SnapxToken}"
    $SnapxYmlContent | Out-File $SnapxYmlFilenamePath -Encoding $Utf8NoBomEncoding
}
