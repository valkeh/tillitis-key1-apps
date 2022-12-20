#!/bin/sh -eu

tkey_provision_tag=v0.0.1
tkey_provision_tag=main

cd "${0%/*}"
. ./common
./check.sh "provision" "$tkey_provision_tag"

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

printf >"$hashf" "hash(%s,%s) %s\n" "$udi" "$pub" "$tkey_provision_tag"

ssh-keygen -Y sign -f "$tillitisprivf" -n file "$hashf"
