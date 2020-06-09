param()

function Resolve-Shell-Dependency {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $Command
    )
    if ($null -eq (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Error "Unable to find executable in environment path: $Command"
    }
}
function Resolve-Windows {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $OSPlatform
    )
    if ($OSPlatform -ne "Windows") {
        Write-Error "Unable to continue because OS version is not Windows but $OSVersion"
    }	
}
function Resolve-Unix {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $OSPlatform
    )
    if ($OSPlatform -ne "Unix") {
        Write-Error "Unable to continue because OS version is not Unix but $OSVersion"
    }	
}
function Write-Output-Colored {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $Message,
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [string] $ForegroundColor = "Green"
    )

    $fc = $host.UI.RawUI.ForegroundColor

    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    Write-Output $Message

    $host.UI.RawUI.ForegroundColor = $fc
} 
function Write-Output-Header { 
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Message
    )

    Write-Host
    Write-Output-Colored -Message $Message -ForegroundColor Green
    Write-Host
}
function Write-Output-Header-Warn {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Message
    )

    Write-Host
    Write-Output-Colored -Message $Message -ForegroundColor Yellow
    Write-Host
}
function Invoke-Command-Clean-Dotnet-Directory {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Directory
    )

    if($false -eq (Test-Path $Directory))
    {
        return
    }

    $Bin = Join-Path $Directory bin
    if(Test-Path $Bin)
    {
        Write-Output "Removing directory: $Bin" 
        Get-ChildItem -Path $Bin -Recurse | Remove-Item -Force -Recurse
    }

    $Obj = Join-Path $Directory obj
    if(Test-Path $Obj)
    {
        Write-Output "Removing directory: $Obj" 
        Get-ChildItem -Path $Obj -Recurse | Remove-Item -Force -Recurse
    }

}
function Invoke-Command-Colored {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Filename,
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [string[]] $Arguments
    )
    $CommandStr = $Filename
    $DashsesRepeatCount = $Filename.Length

    if($Arguments.Length -gt 0)
    {
        $ArgumentsStr = $Arguments -join " "
        $CommandStr = "$Filename $ArgumentsStr"
        $DashsesRepeatCount = $CommandStr.Length
    }

    try {
        # NB! Accessing this property during a CI build will throw.
        # Ref issue: https://github.com/Microsoft/azure-pipelines-tasks/issues/9719
        if([console]::BufferWidth -gt 0)
        {
            $DashsesRepeatCount = [console]::BufferWidth
        }    
    } catch {
        $DashsesRepeatCount = 80
    }

    $DashesStr = "-" * $DashsesRepeatCount

    Write-Output-Colored -Message $DashesStr -ForegroundColor White
    Write-Output-Colored -Message $CommandStr -ForegroundColor Green
    Write-Output-Colored -Message $DashesStr -ForegroundColor White

    try {
        Invoke-Expression $CommandStr
    } finally {
        if($LASTEXITCODE -ne 0) {
            exit 1
        }
    }
}
function Get-Msvs-Toolchain-Instance
{
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet(16)]
        [int] $VisualStudioVersion
    )

    $Ids = 'Community', 'Professional', 'Enterprise', 'BuildTools' | ForEach-Object { 'Microsoft.VisualStudio.Product.' + $_ }
    $Instance = & $CommandVsWhere -version $VisualStudioVersion -products $ids -requires 'Microsoft.Component.MSBuild' -format json `
        | convertfrom-json `
        | select-object -first 1

    return $Instance
}

function Get-Is-String-True
{
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        $Value
    )

    if($Value -ieq "true" -or ($Value -ieq "$true"))
    {
        return $true
    }

    if($Value -eq "1")
    {
        return $true
    }

    return $false
}

function Get-Is-String-False
{
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        $Value
    )

    if($Value -ieq "false" -or ($Value -ieq "$false"))
    {
        return $true
    }

    if($Value -eq "0")
    {
        return $true
    }

    return $false
}

function Use-Msvs-Toolchain 
{
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet(15, 16)]
        [int] $VisualStudioVersion
    )

    Write-Output-Header "Configuring msvs toolchain"

    $script:CommandMsBuild = $null

    $Instance = Get-Msvs-Toolchain-Instance $VisualStudioVersion
    if ($null -eq $Instance) {
        if($VisualStudioVersion -eq 16)
        {
            Write-Error "Visual Studio 2019 was not found on this computer"
            exit 1
        } elseif($VisualStudioVersion -eq 15)
        {
            Write-Error "Visual Studio 2017 was not found on this computer"
            exit 1
        }
    } else {
        if($VisualStudioVersion -eq 16)
        {
            Write-Output "Using Visual Studio 2019 msvs toolset"
        } elseif($VisualStudioVersion -eq 15) {
            Write-Output "Using Visual Studio 2017 msvs toolset"
        } else {
            Write-Error "Unknown Visual Studio version: $VisualStudioVersion"
            exit 1
        }
    }
}

# Build targets

function Invoke-Google-Tests 
{
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $GTestsDirectory,
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $GTestsExe,
        [Parameter(Position = 2, ValueFromPipeline = $true)]
        [string[]] $GTestsArguments 
    )
    try 
    {
        if($null -eq $GTestsArguments) {
            $GTestsArguments = @()
        }
        
        Push-Location $GTestsDirectory
        $GTestsExe = Join-Path $GTestsDirectory $GTestsExe
        $GTestsArguments += "--gtest_output=""xml:./googletestsummary.xml"""        
        Invoke-Command-Colored $GTestsExe $GTestsArguments
    } finally {             
        Pop-Location 
    }
}

function Convert-Boolean-MSBuild {
    param(
        [boolean] $Value
    )
    
    if ($true -eq $Value) {
        return "true"
    }
    
    return "false"
}