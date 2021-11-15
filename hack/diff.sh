#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

DEBUG="${DEBUG:-}"
INCREMENTAL="${INCREMENTAL:-}"
QUICKLY="${QUICKLY:-}"
SYNC="${SYNC:-}"
PARALLET="${PARALLET:-0}"

declare -A DOMAIN_MAP=()

total=0
for image in $(helper::get_source); do
    key="${image%%/*}"
    val="${image#*/}"
    if [[ -v "DOMAIN_MAP[${key}]" ]]; then
        DOMAIN_MAP["${key}"]+=" ${val}"
    else
        DOMAIN_MAP["${key}"]="${val}"
    fi
    total=$((total + 1))
done

LOGFILE="./sync.log"
echo >"${LOGFILE}"

count=0
for domain in "${!DOMAIN_MAP[@]}"; do
    list=$(echo ${DOMAIN_MAP[${domain}]} | tr ' ' '\n' | shuf)
    for image in ${list}; do
        regex="${DEFAULT_REGEX}"
        if [[ "${image#*/}" =~ ":" ]]; then
            regex="${image##*:}"
            image="${image%:*}"
        fi
        count=$((count+1))
        to="$(helper::replace_domain "${domain}/${image}")"
        echo "Syncing ${count}/${total}: ${domain}/${image} to ${to}"
        DEBUG="${DEBUG}" SYNC="${SYNC}" QUICKLY="${QUICKLY}" INCREMENTAL="${INCREMENTAL}" PARALLET="${PARALLET}" FOCUS="${regex}" ./hack/diff-image.sh "${domain}/${image}" "${to}" 2>&1 | tee -a "${LOGFILE}" || {
            echo "Error: diff image ${domain}/${image} $(helper::replace_domain "${domain}/${image}")"
        }
    done
done
