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

tmpf="$(mktemp)"
cleanup() {
  rm -f "$tmpf"
}
trap cleanup EXIT

# TODO so, exactly the same signerapp must be run both when provisioning and
# verifiying
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

hashf="$PWD/tillitis-hash-udi-$udi"

if [ -e "$hashf" ]; then
  fail "$hashf: file exists"
fi

printf >"$hashf" "hash(%s,%s)\n" "$udi" "$pub"

ssh-keygen -Y sign -f "$tillitisprivf" -n file "$hashf"
