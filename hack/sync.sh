#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${ROOT}"

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

for domain in "${!DOMAIN_MAP[@]}"; do
    file="${domain}.yaml"
    list=$(echo ${DOMAIN_MAP[${domain}]} | tr ' ' '\n' | shuf)
    echo "'${domain}':" >"${file}"
    echo "  images-by-tag-regex:" >>"${file}"
    for image in ${list}; do
        regex="${DEFAULT_REGEX}"
        if [[ "${image}" =~ ":" ]]; then
            regex="${image##*:}"
            image="${image%:*}"
        fi
        echo "    '${image}': '${regex}'" >>"${file}"
    done
    ${SKOPEO} sync --all --remove-signatures --src yaml --dest docker -f oci "${file}" $(helper::replace_domain "${domain}")
done
