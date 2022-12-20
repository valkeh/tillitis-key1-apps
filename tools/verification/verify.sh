#!/bin/sh -eu

cd "${0%/*}"
. ./common

hashf="${1:-}"
if [ -z "$hashf" ]; then
  fail "Give me file with the published hash and tag (having a companion .sig file)"
  exit 2
fi

if [ ! -e "$hashf".sig ]; then
  fail "$hashf.sig not found"
fi

tillitispubf="./tillitis-signing-key.pub"
say "Picked up Tillitis public signing key from $tillitispubf"

hash_verifytag="$(cat "$hashf")"
hash="${hash_verifytag% *}"
verifytag="${hash_verifytag#* }"
# TODO check that we're given a proper hash at all?
if [ -z "$hash" ] || [ -z "$verifytag" ]; then
  fail "Could not parse hash and tag in the file"
fi

./check.sh "verify" "$verifytag"

udi="$(runapp)"
pub="$(getpubkey)"
tkeyhash="$(printf "hash(%s,%s)" "$udi" "$pub")"

say "Hash from your TKey (No User-Supplied Secret):"
printf "%s\n" "$tkeyhash"
say "The hash from Tillitis says:"
printf "%s\n" "$hash"

if [ "$tkeyhash" != "$hash" ]; then
  fail "Hashes doesn't match, wrong file?"
fi

say "Verifying the signature of the provided file:"
tmpf="$(mktemp)"
awk >"$tmpf" '{ print $3 " " $1 " " $2 }' "$tillitispubf"
ssh-keygen -Y verify -f "$tmpf" -I "tillitis-signing-key" -n file -s "$hashf".sig <"$hashf"
rm -f "$tmpf"
