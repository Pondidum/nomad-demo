#! /bin/bash

dotnet build HelloApi.sln
dotnet publish --no-build --output ../../.build
7z a helloapi.zip ./.build/* > /dev/null
