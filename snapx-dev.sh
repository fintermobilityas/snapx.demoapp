#!/bin/bash
dotnet build -c Debug ../Snapx/Snapx.csproj
dotnet ../Snapx/bin/Debug/netcoreapp3.1/snapx.dll $*
