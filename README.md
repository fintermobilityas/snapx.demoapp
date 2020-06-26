# Snapx demoapp

A simple cross platform demo for Snapx applications.

![dependabot](https://api.dependabot.com/badges/status?host=github&repo=fintermobilityas/snapx.demoapp)

| Build server | Platforms | Build status |
|--------------|----------|--------------|
| Github Actions | ubuntu-latest, windows-latest | develop ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=develop) |
| Github Actions | ubuntu-latest, windows-latest | master ![snapx.demoapp](https://github.com/fintermobilityas/snapx.demoapp/workflows/demoapp/badge.svg?branch=master) |

## Tutorial

### Getting started

#### List all available releases

![snapx list](https://media.githubusercontent.com/media/fintermobilityas/snapx.demoapp/develop/docs/snapxlist.png)

#### What does the installer look like?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx/develop/docs/snapxinstaller.gif" width="794" />

#### How can I update my application?

<img src="https://media.githubusercontent.com/media/fintermobilityas/snapx.demoapp/develop/docs/demoappupdate.gif" width="794" />

#### Install snapx dotnet global tool

- `dotnet tool update snapx -g`
- `git clone https://github.com/fintermobilityas/snapx.demoapp.git`
- `cd snapx.demoapp`
- `snapx`

##### Restore offline/web installers

- `snapx restore -i`
