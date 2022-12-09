#!/bin/sh -eu

cd "${0%/*}"
. ./common

# TODO
# check for correct signer app?
# store used signer-app-hash along with "tkey-hash"?
# building manually requires correct toolchain...

files="../../tkey-runapp ../../tkey-sign ../../apps/signer/app.bin"
for f in $files; do
  if [ ! -e "$f" ]; then
    msg=$(cat <<EOF
The file $f is missing.
To provision or verify, the signer app and host programs needs to be built
from the "$TKEY_VERIFY_TAG". You can do this manually, or by running the
build-in-container.sh script (requires docker/podman).
EOF
)
    fail "$msg"
  fi
done

for f in $files; do
  cp -af "$f" .
done
