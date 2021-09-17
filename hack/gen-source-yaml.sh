#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_REGEX='^v?\d+(\.\d+){0,2}(-.+)?$|^latest$'
images="$(cat source.txt | tr -d ' ' | grep -v -E '^$' | grep -v -E '^#')"

declare -A DOMAIN_MAP=()

for image in $images; do
    key="${image%%/*}"
    val="${image#*/}"
    if [[ -v "DOMAIN_MAP[${key}]" ]]; then
        DOMAIN_MAP["${key}"]+=" ${val}"
    else
        DOMAIN_MAP["${key}"]="${val}"
    fi
done

for domain in "${!DOMAIN_MAP[@]}"; do
    list=$(echo ${DOMAIN_MAP[${domain}]} | tr ' ' '\n' | shuf)
    echo "'${domain}':"
    echo "  images-by-tag-regex:"
    for image in ${list}; do
        regex="${DEFAULT_REGEX}"
        if [[ "${image}" =~ ":" ]]; then
            regex="${image##*:}"
            image="${image%:*}"
        fi
        echo "    '${image}': '${regex}'"
    done
done
