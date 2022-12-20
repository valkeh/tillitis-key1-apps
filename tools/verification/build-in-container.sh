#!/bin/sh -eu

cd "${0%/*}"
. ./common

tag="${1?pass a tag}"

crun=docker
cname="tkey-build"

$crun run -it --name "$cname" \
      --mount type=bind,source="$(pwd)/containerbuild",target=/containerbuild \
      tkey-builder \
      /bin/bash /containerbuild "$tag"

# Copy to expected locations
$crun cp "$cname":/tillitis-key1-apps/tkey-runapp ../../
$crun cp "$cname":/tillitis-key1-apps/tkey-sign ../../
$crun cp "$cname":/tillitis-key1-apps/apps/signer/app.bin ../../apps/signer/

$crun rm "$cname"
