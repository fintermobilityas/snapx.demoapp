param(
    [Parameter(Position = 0, ValueFromPipeline)]
    [string] $Version = "0.0.0",
    [Parameter(Position = 1, ValueFromPipeline)]
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Release",
    [Parameter(Position = 2, ValueFromPipeline)]
    [switch] $Nupkg,
    [Parameter(Position = 3, ValueFromPipeline)]
    [string] $SnapxToken = $null
)

$WorkingDirectory = Split-Path -parent $MyInvocation.MyCommand.Definition
. $WorkingDirectory\common.ps1

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

$BuildOutputDirectory = Join-Path $WorkingDirectory build\$Version
$SnapxYmlFilenamePath = Join-Path $WorkingDirectory .snapx\snapx.yml

Resolve-Shell-Dependency dotnet

Invoke-Command-Colored dotnet @(
    ("build {0}" -f (Join-Path $WorkingDirectory Demoapp.sln))
    "/p:Version=$Version",
    "/p:GeneratePackageOnBuild=$Nupkg"
    "--output $BuildOutputDirectory"
    "--configuration $Configuration"
)

if($SnapxToken -ne $null) {
    $SnapxYmlContent = (Get-Content $SnapxYmlFilenamePath) -replace "token:.*", "token: ${SnapxToken}"
    $SnapxYmlContent | Out-File $SnapxYmlFilenamePath -Encoding $Utf8NoBomEncoding
}
