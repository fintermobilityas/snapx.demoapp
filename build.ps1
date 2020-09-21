param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [ValidateSet("Publish", "Set-Snapx-Token")]
    [string] $Target = "Publish",
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string] $Version = "0.0.0",
    [Parameter(Position = 1, ValueFromPipeline = $true)]
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Release",
    [Parameter(Position = 2, ValueFromPipeline = $true)]
    [string] $SnapxToken = $null,
    [Parameter(Position = 3, ValueFromPipeline = $true)]
    [ValidateSet("win-x86", "win-x64", "linux-x64", "linux-arm64")]
    [string] $Rid
)

$WorkingDirectory = Split-Path -parent $MyInvocation.MyCommand.Definition
. $WorkingDirectory\common.ps1

$Framework = "net5.0"
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

$BuildOutputDirectory = Join-Path $WorkingDirectory .snapx\artifacts\demoapp\$Rid\$Version
$SnapxYmlFilenamePath = Join-Path $WorkingDirectory .snapx\snapx.yml

switch($Target) {
    "Publish" {
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

    }
    "Set-Snapx-Token" {

        Write-Output-Colored "Replacing snapx lock token"

        $SnapxYmlContent = (Get-Content $SnapxYmlFilenamePath) -replace "token:.*", "token: ${SnapxToken}"

        if($SnapxYmlContent -match "token: ${SnapxToken}") {
            $SnapxYmlContent | Out-File $SnapxYmlFilenamePath -Encoding $Utf8NoBomEncoding
            Write-Output "Successfully replaced snapx lock token"
            exit 0
        }

        Write-Error "Unknown error replacing snapx lock token"

        exit 0
    }
}