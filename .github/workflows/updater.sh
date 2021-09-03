#!/bin/bash

echo "${#DOWNLOAD_URL[@]} available asset(s)"

for asset_url in $DOWNLOAD_URL; do

echo "Handling asset at $asset_url"

# Create the temporary directory
tempdir="$(mktemp -d)"

# Download sources and calculate checksum
filename=${asset_url##*/}
curl --silent -4 -L $asset_url -o "$tempdir/$filename"
checksum=$(sha256sum "$tempdir/$filename" | head -c 64)

# Delete temporary directory
rm -rf $tempdir

# Get extension
if [[ $filename == *.tar.gz ]]; then
extension=tar.gz
else
extension=${filename##*.}
fi

case $asset_url in
  *"admin"*)
    src="app"
    ;;
  *"update"*)
    src="app-upgrade"
    ;;
  *)
    src=""
    ;;
esac

if [ -z "$src" ]; then
# Rewrite source file
cat <<EOT > conf/$src.src
SOURCE_URL=$asset_url
SOURCE_SUM=$checksum
SOURCE_SUM_PRG=sha256sum
SOURCE_FORMAT=$extension
SOURCE_IN_SUBDIR=true
SOURCE_FILENAME=
EOT
fi

done
