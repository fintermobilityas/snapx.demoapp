#!/bin/bash
dotnet build -c Debug ../Snapx/src/Snapx.csproj
dotnet ../Snapx/src/Snapx/bin/Debug/net5.0/snapx.dll $*
