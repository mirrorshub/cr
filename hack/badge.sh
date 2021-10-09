#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

QUICKLY="${QUICKLY:-}"
LOGFILE="./sync.log"
sync="$(cat "${LOGFILE}" | grep " SYNCHRONIZED: " | wc -l | tr -d ' ' || :)"
unsync="$(cat "${LOGFILE}" | grep " NOT-SYNCHRONIZED: " | wc -l | tr -d ' ' || :)"
sum=$(($sync + $unsync))

if [[ "${QUICKLY}" == "true" ]]; then
    echo "https://img.shields.io/badge/Sync-${sync}%2F${sum}-blue"
    wget "https://img.shields.io/badge/Sync-${sync}%2F${sum}-blue" -O badge.svg
else
    echo "https://img.shields.io/badge/Deep%20Sync-${sync}%2F${sum}-blue"
    wget "https://img.shields.io/badge/Deep%20Sync-${sync}%2F${sum}-blue" -O badge.svg
fi
