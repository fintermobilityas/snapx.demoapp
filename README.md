# 📖 Snapx Demo Application

![dependabot](https://api.dependabot.com/badges/status?host=github&repo=fintermobilityas/snapx.demoapp) [![Gitter](https://badges.gitter.im/fintermobilityas-snapx/community.svg)](https://gitter.im/fintermobilityas-snapx/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) ![License](https://img.shields.io/github/license/fintermobilityas/snapx.demoapp.svg)

![Size](https://img.shields.io/github/repo-size/fintermobilityas/snapx.svg) 

| Build server | Platforms | Build status |
|--------------|----------|--------------|
| Github Actions | ubuntu-latest, windows-latest | develop ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=develop) |
| Github Actions | ubuntu-latest, windows-latest | master ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=master) |

## Tutorial

A simple xplat demo for installing and updating an .NET application. **[snapx](https://github.com/fintermobilityas/snapx)** is a powerful xplat .NET application with built-in support for delta updates, release channels (test, staging, production) and automatic deployment using GitHub Actions. Updates can delivered via NuGet or network share (UNC).

### Introduction

This demo application intends to demonstrate how you can build and release updates for this application on your local computer without requiring a NuGet server.
In order to get started you need to run `snapx restore --build-installers` which will download all assets required to create a new release.

### The `.snapx` directory structure

`snapx` uses a concept called variable expansion (see below). By the default the following directory layout is used:

- **`.snapx/artifacts`** contains your build artifacts. If you run `build.ps1 -Version 1.0.0` a new directory will be created `.snapx/artifacts/$app/$rid/1.0.0`.
- **`.snapx/assets`** contains assets for your applications. You don't need to worry about moving your existing assets to this directory it is only used for setting this application's icon. This can be seen if you open [snapx.yml](https://github.com/fintermobilityas/snapx.demoapp/blob/develop/.snapx/snapx.yml#L43).
- **`.snapx/installers`** contains installers for your applications. There are two types of installers `offline` and `web`. The installers are only built when you run `snapx pack` or `snapx restore -i`. 
- **`.snapx/packages`** contains the nuget packages `.nupkg` required to build a new release for your applications. There are two types of `nupkgs`, delta and full. A full package is only built when creating a `genesis` (full) release which contains everything required to run your application. When you build the next release a `delta` nupkg will be created. This `nupkg` contains only the files that has been updated or deleted. A binary diff algorithm has been implemented so only the bits that has change is included in your `delta` nupkg.

**Variable expansion**

- `$app` is the application name.
- `$rid` is a [dotnet runtime identifier](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog).

### The `.snapx/snapx.yml` manifest file

`snapx.yml` can be thought of as a `nuspec` for your applications. It allows you to customize which installer types that should be built, what icons that should be created during installation, persistent assets etc. 

### Required software for this tutorial

- [.NET SDK 5.0](https://dotnet.microsoft.com/download/dotnet/5.0)
- [Powershell v7](https://github.com/PowerShell/powershell/releases)
- [snapx](https://github.com/fintermobilityas/snapx)

1. Please follow installation instructions for .NET SDK that can be installed by visiting this [link](https://dotnet.microsoft.com/download/dotnet/5.0).
2. After installing the SDK the next step is to install Powershell (only a required for this demo). You can install Powershell running `dotnet tool update powershell -g`. This command installs Powershell as [global dotnet tool](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-tool-install) on your computer machine.
3. The final step is to install `snapx` by running `dotnet tool update snapx -g`

### Cloning the repository

- `git clone https://github.com/fintermobilityas/snapx.demoapp.git`

### Building and updating the demo application

This can be done by editing `nuget.config` found in this directory. Change `demoapp-publish`, `demoapp-update` to `c:\demoapp_nupkgs`. On Linux you can use `/tmp/demoapp_nupkgs`. 

***Windows***

1. Start a powershell terminal
2. `$env:SNAPX_DEMOAPP_LOCK_TOKEN="<insert random guid here>"`
3. `.\build.ps1 -Version 1.0.0` (Build output can be found in in `.snapx/artifacts/1.0.0` directory)
4. `snapx pack demoapp -r win-x64 -v 1.0.0`
  
There should be two packages in your local NuGet feed, e.g. `c:\demoapp_nupkgs`

5. Execute `.snapx/installers/win-x64/Setup-win-x64-demoapp-test-web.exe`

The application should now be running. Repeat step 3. and 4. and increment the minor version by 1, e.g. `.\build.ps1 -Version 1.0.1`.

6. Tap the `Check for updates` button. The application should now update to version `1.0.1`

***Linux***

1. Open a powershell terminal (pwsh)
2. `$env:SNAPX_DEMOAPP_LOCK_TOKEN="<insert random guid here>"`
3. `.\build.ps1 -Version 1.0.0` (Build output can be found in in `.snapx/artifacts/1.0.0` directory)
4. `snapx pack demoapp -r linux-x64 -v 1.0.0`
  
There should be two packages in your local NuGet feed, e.g. `/tmp/demoapp_nupkgs`

5. `chmod +x .snapx/installers/linux-x64/Setup-linux-x64-demoapp-test-web | sh`

The application should now be running. Repeat step 3. and 4. and increment the minor version by 1, e.g. `.\build.ps1 -Version 1.0.1`.

6. Tap the `Check for updates` button. The application should now update to version `1.0.1`

### Unattended updates

`snapx` updates can be installed without user interaction. This is great for unattended applications. The demo application has button that is called `Check for updates`. There is nothing wrong with creating a background job (using either a `Thread`, `Task` or `Hangfire`) to check for updates every minute.

### Delta updates

`snapx` automatically creates a delta `nupkg` each time you run `snapx pack` command. This means that your end-users only have to download the bits that changes between releases. This is great for users that do not have a fast broadband connection or customers that live in rural areas with poor cellphone reception.

### Release channels

Google Chrome has three different release cadence channels (`canary`, `beta`, `stable`). The same concept is implemented in snapx. In this demo application there are two channels available, `test` and `production`. Each commit pushed to the `develop` branch produces a delta update that can be consumed by end-users. This is not a recommended practice though, it's only for demoing purposes. You should push releases when merging to `master` branch. 

You can list available release by running `snapx` inside the directory of this repository. It will render an overview for all your release.

![snapx list](https://media.githubusercontent.com/media/fintermobilityas/snapx.demoapp/develop/docs/snapxlist.png)

### Promoting releases

Because releases are always pushed to the first channel defined in your [`snapx.yml`](https://github.com/fintermobilityas/snapx.demoapp/edit/develop/README.md) these releases are not available to users that consumes updates using the demoapp's `production` channel. In order for them to receive this update you have to promote the release. You can list available releases by running `snapx` inside this repository directory.

If you want to promote the current version for the `test` channel run the following command `snapx promote demoapp -r win-x64 -c test`. Then current release will be promoted to the `production` channels. 

### The supervisor

The supervisor monitors your applications. Snapx uses a stub executable that is responsible for starting your application. All shortcuts that are created during installation uses this stub application. Common use cases are automatic restart of your application after an unattended update or your application crashed. The demo application shows you how to start and stop the supervisor. It's optional if you want to enable this functionality.

### Is a CI server required?

No. You can push updates from your local machine to a local directory, a `UNC path` or a `NuGet` server such as `Github Packages`, `nuget.org`, `myget.org` etc.. Using a `NuGet` server is the preferred way because you never have to worry about your storing your release nupkgs.

### Different types of installers

snapx supports two types of installers, `offline` and `web`. The `offline` installer contains all the dependencies required to install your application. An offline installer has to be built each time you `pack` a new release. The `web` installer only has to be built once or when there has been an update to the `snapx` tool itself. This means that the `web` installer will always download the latest version of your application.

Because installers are built using your dependency graph you do not have to worry about storing them on a file share, or an external blob service such as Amazon S3, Azure Blobs etc. Installers can be rebuilt on-the-fly by running `snapx restore -i`. This repository uses a [`GitHub Actions Workflow`](https://github.com/fintermobilityas/snapx.demoapp/blob/develop/.github/workflows/dotnet-core.yml) to build the installers. When `develop` is merged into `master` the installers will be automatically attached to the `GitHub` release.

#### What directory is used when installing my application?

**Windows**: `%LOCALAPPDATA%\demoapp`
**Linux**: `$HOME/.local/demoapp`

### Persistent assets

Its common to have assets that should be persisted as the installer can be ran multiple times. In your `.snapx/snapx.yml` file you can set relative paths that will never be deleted when an application is reinstalled. For example if you add `application.json` to `persistentAssets` section this file will never be deleted from your application installation directory. If you add `myimportantfolder` then this directory will never be deleted.

### What does the installer look like?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx/develop/docs/snapxinstaller.gif" width="794" />

### What does the update process look like?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx/develop/docs/demoappupdate.gif" width="794" />
