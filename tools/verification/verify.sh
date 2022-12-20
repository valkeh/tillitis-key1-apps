#!/bin/sh -eu

cd "${0%/*}"
. ./common
./check.sh

# TODO the hashfile should also contain which tag of signer app that should be
# used for verification
hashf="${1:-}"
if [ -z "$hashf" ]; then
  fail "Give me file with the published hash (having a companion .sig file)"
  exit 2
fi

if [ ! -e "$hashf".sig ]; then
  fail "$hashf.sig not found"
fi

tillitispubf="./tillitis-signing-key.pub"
say "Picked up Tillitis public signing key from $tillitispubf"

udi="$(runapp)"
pub="$(getpubkey)"

tkeyhash="$(printf "hash(%s,%s)" "$udi" "$pub")"
# TODO check that we're given a proper hash at all?
filehash="$(cat "$hashf")"

say "Hash from your TKey (No User-Supplied Secret):"
printf "%s\n" "$tkeyhash"
say "The hash from Tillitis is:"
printf "%s\n" "$filehash"

if [ "$tkeyhash" != "$filehash" ]; then
  fail "Hashes doesn't match, is it a hash for the TKey with same UDI as yours?"
fi

say "Verifying the signature of that file:"
tmpf="$(mktemp)"
awk >"$tmpf" '{ print $3 " " $1 " " $2 }' "$tillitispubf"
ssh-keygen -Y verify -f "$tmpf" -I "tillitis-signing-key" -n file -s "$hashf".sig <"$hashf"
rm -f "$tmpf"
