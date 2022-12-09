#!/bin/sh -eu

cd "${0%/*}"
. ./common

crun=docker
cname="tkey-build"

$crun run -it --name "$cname" \
      --mount type=bind,source="$(pwd)/containerbuild",target=/containerbuild \
      tkey-builder \
      /bin/bash /containerbuild "$TKEY_VERIFY_TAG"

# Copy to expected locations
$crun cp "$cname":/tillitis-key1-apps/tkey-runapp ../../
$crun cp "$cname":/tillitis-key1-apps/tkey-sign ../../
$crun cp "$cname":/tillitis-key1-apps/apps/signer/app.bin ../../apps/signer/

$crun rm "$cname"
