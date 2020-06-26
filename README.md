# 📖 Snapx Demo Application

A simple xplat demo for installing and updating an .NET application. **[snapx](https://github.com/fintermobilityas/snapx)** is a powerful xplat .NET application with built-in support for delta updates, release channels (test, staging, production) and automatic deployment using GitHub Actions. Updates can delivered via NuGet or network share (UNC).

![dependabot](https://api.dependabot.com/badges/status?host=github&repo=fintermobilityas/snapx.demoapp) [![Gitter](https://badges.gitter.im/fintermobilityas-snapx/community.svg)](https://gitter.im/fintermobilityas-snapx/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) ![License](https://img.shields.io/github/license/fintermobilityas/snapx.demoapp.svg)

![Size](https://img.shields.io/github/repo-size/fintermobilityas/snapx.svg) 

| Build server | Platforms | Build status |
|--------------|----------|--------------|
| Github Actions | ubuntu-latest, windows-latest | develop ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=develop) |
| Github Actions | ubuntu-latest, windows-latest | master ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=master) |

## Tutorial

### Required software

- .NET Core SDK 3.1
- Powershell v7

Please follow installation instructions which can be downloaded by visit this [link](https://dotnet.microsoft.com/download/dotnet-core/3.1).
After installing .NET Core SDK you must install Powershell. You can install it as a global dotnet tool by executing `dotnet tool update powershell -g`. 

**IMPORTANT** You must install the snapx dotnet tool. This can be done by executing `dotnet tool update snapx -g`. This will install the snapx tool globally on your machine. 

- `dotnet tool update snapx -g`
- `git clone https://github.com/fintermobilityas/snapx.demoapp.git`

### `snapx.yml`

The `snapx.yml` file found in `.snapx/snapx.yml` (in this repository) describes the features your application requires. Monorepos are supported so you can have many applications in this file. 

### Unattended updates

`snapx` updates can be installed without user interaction. This is great for unattended applications. The demo application has button that is called `Check for updates`. There is nothing wrong with creating a background job (using either a `Thread`, `Task` or `Hangfire`) to check for updates every minute.

### Delta updates

`snapx` automatically creates a delta `nupkg` each time you run `snapx pack` command. This means that your end-users only have to download the bits that changes between releases. This is great for users that do not have a fast broadband connection or customers that live in rural areas with poor cellphone reception.

### What is a release channel?

Google Chrome has three different release cadence channels (canary, beta, stable). The same concept is implemented in snapx. In this demo application there are two channels available, `test` and `production`. Each commit pushed to the `develop` branch produces a delta update that can be consumed by end-users. This is not a recommended practice though, it's only for demoing purposes. You should push releases when merging to `master` branch. 

### What is a supervisor?

A supervisor monitors your application. Snapx deploys a stub executable with your application. The shortcuts that are created during installation always points to this stub executable. Common use cases are automatic restart of application after an update or your application has experienced a crash. The demo application shows you how to start and stop the supervisor. It's entirely optional if you want to enable it.

### How can I test the update mechanism without pushing packages to a NuGet feed?

This can be done by editing `nuget.config` found in this directory. Change `demoapp-publish`, `demoapp-update` to `c:\demoapp_nupkgs`. On Linux you can use `/tmp/demoapp_nupkgs`. 

***Windows***

1. Start a powershell terminal
2. `$env:SNAPX_DEMOAPP_LOCK_TOKEN="<insert random guid here>"`
3. `.\build.ps1 -Version 1.0.0` (Build output can be found in in `.snapx/artifacts/1.0.0` directory)
4. `snapx pack demoapp -r [win-x64|linux-x64] -v 1.0.0`
  
There should be two packages in your local NuGet feed, e.g. `c:\demoapp_nupkgs`

5. Execute `.snapx/installers/win-x64/Setup-win-x64-demoapp-test-web.exe`

The application should now be running. Repeat step 3. and 4. and increment the minor version by 1, e.g. `.\build.ps1 -Version 1.0.1`.

6. Tap the `Check for updates` button. The application should now update to version `1.0.1`

***Linux***

1. Open a powershell terminal (pwsh)
2. `$env:SNAPX_DEMOAPP_LOCK_TOKEN="<insert random guid here>"`
3. `.\build.ps1 -Version 1.0.0` (Build output can be found in in `.snapx/artifacts/1.0.0` directory)
4. `snapx pack demoapp -r [win-x64|linux-x64] -v 1.0.0`
  
There should be two packages in your local NuGet feed, e.g. `/tmp/demoapp_nupkgs`

5. `chmod +x .snapx/installers/win-x64/Setup-win-x64-demoapp-test-web | sh`

The application should now be running. Repeat step 3. and 4. and increment the minor version by 1, e.g. `.\build.ps1 -Version 1.0.1`.

6. Tap the `Check for updates` button. The application should now update to version `1.0.1`

### Is a CI server required?

No. You can push updates from your local machine to a local directory, `UNC path` or a `NuGet` server such as `Github Packages`, `nuget.org` and `MyGet`. Using a `NuGet` server is the preferred option as you never have to worry about your release nupkgs.

### What kind of installers are available?

Snapx offers two types of installers, `offline` and `web`. The `offline` installer contains all the dependencies required to install your application. An offline installer has to be built each time you `pack` a new release. The `web` installer only has to be built once or when there has been updates to the `snapx` tool itself. This means that the `web` installer will always download the latest version of your application.

Because the installers are built using your dependency graph you never have to store them anywhere. They can be rebuilt on-the-fly from the command line. This repository uses `GitHub Actions` to build the installers. When `develop` is merged into `master` the installers will be automatically attached to the `GitHub` release.

You can restore the installers by executing `snapx restore --installers`. NB! You must execute this command inside this directory.

Installation directories:

**Windows**: `%LOCALAPPDATA%\demoapp`
**Linux**: `$HOME/.local/demoapp`

### How can I promote a release to production?

`snapx list`
`snapx promote demoapp -r [win-x64|linux-x64] -c test`

### Persistent assets

It's common to have assets that should be persisted even if the installer is ran multiple times. In your `.snapx/snapx.yml` file you can set relative paths that will never be deleted when an application is reinstalled. For example if you add `application.json` to `persistentAssets` section this file will never be deleted. If you add `myimportantfolder` then this directory will never be deleted.

### Listing available release for all available channels

`snapx list`

![snapx list](https://media.githubusercontent.com/media/fintermobilityas/snapx.demoapp/develop/docs/snapxlist.png)

### What does the installer look like?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx/develop/docs/snapxinstaller.gif" width="794" />

### What does the update process look like?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx/develop/docs/demoappupdate.gif" width="794" />
