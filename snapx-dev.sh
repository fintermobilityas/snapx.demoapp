#!/bin/bash
dotnet build -c Debug ../snapx/src/Snapx.csproj
dotnet ../snapx/src/Snapx/bin/Debug/net5.0/snapx.dll $*
