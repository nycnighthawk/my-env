#!/bin/bash

_s_path="./mycabundle.pem"

function show_help() {
  echo "Usage: $(basename "$0") [--path <path>] [-h|--help]"
  echo "Options:"
  echo "  --path <path>  Set the path to the specified value"
  echo "  -h, --help     Display this help message"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --path)
    _s_path="$2"
    shift 2
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
done

_s_dirname=$(dirname "${_s_path}")
_s_dirname=$(readlink -f "${_s_dirname}")
_s_filename=$(basename "${_s_path}")

echo "ca bundle exported to:"
echo "directory: ${_s_dirname}"
echo "filename: ${_s_filename}"
mkdir -p "${_s_dirname}"
cd "${_s_dirname}"
rm -f tmp_bundle_1.pem tmp_bundle_2.pem
security export -t certs -f pemseq \
  -k /System/Library/Keychains/SystemRootCertificates.keychain \
  -o tmp_bundle_1.pem >/dev/null 2>&1
security export -t certs -f pemseq \
  -k /Library/Keychains/System.keychain \
  -o tmp_bundle_2.pem >/dev/null 2>&1
cat tmp_bundle_1.pem tmp_bundle_2.pem >>"${_s_filename}"
rm -f tmp_bundle_1.pem tmp_bundle_2.pem
