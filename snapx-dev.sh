#!/bin/bash
dotnet build -c Debug ../Snapx/src/Snapx.csproj
dotnet ../Snapx/src/Snapx/bin/Debug/netcoreapp3.1/snapx.dll $*
