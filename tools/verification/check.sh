#!/bin/sh -eu

cd "${0%/*}"
. ./common

verb="${1?pass the verb}"
tag="${2?pass a tag}"

# TODO
# would it make sense to check for correct signer app by hash?
# instead of or in addition to the tag provided along with the "tkey-hash".
# building manually requires correct toolchain...

files="../../tkey-runapp ../../tkey-sign ../../apps/signer/app.bin"
for f in $files; do
  if [ ! -e "$f" ]; then
    msg=$(cat <<EOF
The file $f is missing.
To $verb, the signer app and host programs needs to be built
from the "$tag". You can do this manually, or by running a script
(requires docker):

  build-in-container.sh $tag
EOF
)
    fail "$msg"
  fi
done

for f in $files; do
  cp -af "$f" .
done
