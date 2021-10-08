#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

DEBUG="${DEBUG:-}"
INCREMENTAL="${INCREMENTAL:-}"
QUICKLY="${QUICKLY:-}"
PARALLET="${PARALLET:-0}"

declare -A DOMAIN_MAP=()

for image in $(helper::get_source); do
    key="${image%%/*}"
    val="${image#*/}"
    if [[ -v "DOMAIN_MAP[${key}]" ]]; then
        DOMAIN_MAP["${key}"]+=" ${val}"
    else
        DOMAIN_MAP["${key}"]="${val}"
    fi
done

LOGFILE="./sync.log"
echo >"${LOGFILE}"

count=0
for domain in "${!DOMAIN_MAP[@]}"; do
    list=$(echo ${DOMAIN_MAP[${domain}]} | tr ' ' '\n' | shuf)
    for image in ${list}; do
        regex="${DEFAULT_REGEX}"
        if [[ "${image}" =~ ":" ]]; then
            regex="${image##*:}"
            image="${image%:*}"
        fi
        DEBUG="${DEBUG}" QUICKLY="${QUICKLY}" INCREMENTAL="${INCREMENTAL}" PARALLET="${PARALLET}" FORUS="${regex}" ./hack/diff-image.sh "${domain}/${image}" "$(helper::replace_domain "${domain}")/${image}" 2>&1 | tee -a "${LOGFILE}" || {
            echo "Error: diff image ${domain}/${image} $(helper::replace_domain ${domain})/${image}"
        }
    done
done

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
