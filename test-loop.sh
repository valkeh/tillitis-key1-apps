#!/bin/bash

# Set the environment variable USB_DEVICE to connect to a specific key
if [[ -z "${USB_DEVICE}" ]]; then
  portflag=
else
  portflag="--port ${USB_DEVICE}"
fi

speedflag=  # use default
#speedflag="--speed 62500"

cd "${0%/*}" || exit 1

#make clean
make

./runapp $portflag $speedflag --file apps/signerapp/app.bin || exit 1

c=0
t=$(date +%s)
while true; do
  # 128 bytes becomes 1 msg with 127 bytes and 1 msg with 1 byte
  dd 2>/dev/null if=/dev/urandom of=rand1k bs=128 count=1
  if ! ./tk-sign $portflag $speedflag --file ./rand1k; then
    exit 1
  fi
  (( c++ ))
  printf "loop count: %d, seconds passed: %d\n" "$c" "$(($(date +%s) - t))"
done
