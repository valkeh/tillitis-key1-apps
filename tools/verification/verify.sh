#!/bin/sh -eu

cd "${0%/*}"
. ./common
./check.sh

# TODO the hashfile should also contain which tag of signer app that should be
# used for verification
hashf="${1:-}"
if [ -z "$hashf" ]; then
  fail "Give me file with the published hash (having a companion .sig file)\n"
  exit 2
fi

if [ ! -e "$hashf".sig ]; then
  fail "$hashf.sig not found"
fi

tillitispubf="./tillitis-signing-key.pub"
say "Picked up Tillitis public signing key from $tillitispubf"

tmpf="$(mktemp)"
cleanup() {
  rm -f "$tmpf"
}
trap cleanup EXIT

if ! ./tkey-runapp >"$tmpf" ./app.bin; then
  fail "We didn't load the signer app, bailing out! Please re-insert the TKey."
fi
udi="$(sed -n "s/udi: *\([:0-9a-z]\+\)/\1/ip" "$tmpf" | tr -d ":" | tr A-Z a-z)"
if [ -z "$udi" ]; then
  fail "Failed to get UDI"
fi

if ! ./tkey-sign >"$tmpf" --show-pubkey; then
  cat "$tmpf"
  fail "tkey-sign failed somehow?"
fi

pub="$(cat "$tmpf")"
if ! printf "%s" "$pub" | grep -q "^[0-9a-z]\+$"; then
  fail "Failed to get publickey?"
fi

tkeyhash="$(printf "hash(%s,%s)" "$udi" "$pub")"
# TODO check that we're given a proper hash at all?
filehash="$(cat "$hashf")"

say "Hash from your TKey (No User-Supplied Secret):"
printf "%s\n" "$tkeyhash"
say "The signed hash from Tillitis says:"
printf "%s\n" "$filehash"

if [ "$tkeyhash" != "$filehash" ]; then
  fail "Hashes doesn't match, wrong file?"
fi

say "Verifying the signature of that file:"
awk >"$tmpf" '{ print $3 " " $1 " " $2 }' "$tillitispubf"
ssh-keygen -Y verify -f "$tmpf" -I "tillitis-signing-key" -n file -s "$hashf".sig <"$hashf"
