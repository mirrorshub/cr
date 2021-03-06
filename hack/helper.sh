#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT="${ROOT:-$(dirname "${BASH_SOURCE}")/..}"
DEFAULT_REGEX='^v?[0-9]+(\.[0-9]+){0,2}(-.+)?$|^[a-z]+$'
SKOPEO="${SKOPEO:-skopeo}"
ROOT=$(realpath ${ROOT})

function helper::replace_domain() {
    local domain="${1}"
    local file="${2:-domain.txt}"
    local match_key=""
    local match_val=""
    for line in $(cat ${file}); do
        line="${line/ /}"
        if [[ "${line}" == "" ]]; then
            continue
        fi

        key="${line%=*}"
        val="${line##*=}"
        if [[ "${key}" == "" || "${val}" == "" ]]; then
            continue
        fi

        if [[ "${domain}" =~ ^${key} ]]; then
            echo "${domain}" | sed -e "s#^${key}#${val}#"
            return 0
        fi
    done
    echo "Error: domain ${domain} not found"
    return 1
}

function helper::get_source() {
    local source="${1:-source.txt}"
    cat "${source}" | tr -d ' ' | grep -v -E '^$' | grep -v -E '^#'
}
