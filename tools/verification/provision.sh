#!/bin/sh -eu

cd "${0%/*}"
. ./common
./check.sh

# TODO producing the private key here...
tillitisprivf="./tillitis-signing-key"
if [ ! -e "$tillitisprivf" ]; then
  umask 0077
  ssh-keygen -t ed25519 -N "" -C "tillitis-signing-key" -f "$tillitisprivf"
fi

udi="$(runapp)"
pub="$(getpubkey)"

hashf="$PWD/tillitis-hash-udi-$udi"

if [ -e "$hashf" ]; then
  fail "$hashf: file exists"
fi

printf >"$hashf" "hash(%s,%s)\n" "$udi" "$pub"

ssh-keygen -Y sign -f "$tillitisprivf" -n file "$hashf"
