#!/usr/bin/env bash
set -eu -o pipefail

readonly E_USAGE=99
readonly SCRIPTNAME="${0##*/}"

if [[ "${_DEBUG:-}" == "true"  ]]; then
  set -x
fi

function usage() {
  cat >&2 <<EOF
Usage:
  ./${SCRIPTNAME} -p param1  

Example:
  ./${SCRIPTNAME} -p param1
    
EOF

  exit "${E_USAGE}"
}

function main() {
  declare param1

  while getopts ":p:" optchar; do
    case "${optchar}" in
        p)
          param1="${OPTARG}"
          ;;
        *)
          echo "ERROR: Unknown flag '${OPTARG}'" >&2
          usage
          ;;
      esac
  done

  if [[ -z "${param1+x}" ]]; then
    usage
  fi

  echo "Script arguments:"
  for i in "$@"; do
    echo "${i}"
  done
}

main "$@"
