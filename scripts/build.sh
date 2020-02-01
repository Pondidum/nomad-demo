#!/bin/bash -e

output_dir=".artifacts"

mkdir -p "$output_dir"
rm -rf $output_dir/*.zip

pushd apps

find ./src -iname "*.csproj" | while read project_path; do

    project_name=$(basename "$project_path" .csproj)

    dotnet publish "$project_path" --output "bin/$project_name"

    publish_path="./bin/$project_name"
    output_zip="../$output_dir/$project_name.zip"

    7z a "$output_zip" "$publish_path/*" > /dev/null

done

popd
