#! /bin/bash

rm -rf ./.build/*.zip

dotnet publish --output "bin/publish"

find ./src -iname *.csproj | while read line; do

    project_name=$(basename "$line" .csproj)

    publish_path="./src/$project_name/bin/publish"
    output_path="./.build/$project_name.zip"

    7z a "$output_path" "$publish_path/*" > /dev/null

done
