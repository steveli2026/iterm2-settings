#!/bin/bash

set -euo pipefail

DOMAIN="com.googlecode.iterm2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PLIST="${SCRIPT_DIR}/settings/${DOMAIN}.plist"
ASSUME_YES=false

usage() {
  printf 'Usage: %s [--yes]\n' "$0"
}

for arg in "$@"; do
  case "$arg" in
    --yes|-y)
      ASSUME_YES=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: this installer only supports macOS." >&2
  exit 1
fi

for command_name in defaults plutil pgrep; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: required command not found: ${command_name}" >&2
    exit 1
  fi
done

if [[ ! -f "$SOURCE_PLIST" ]]; then
  echo "Error: settings plist not found: ${SOURCE_PLIST}" >&2
  exit 1
fi

plutil -lint "$SOURCE_PLIST" >/dev/null

if pgrep -x iTerm2 >/dev/null 2>&1; then
  echo "Error: iTerm2 is running. Quit it completely, then run this installer again." >&2
  exit 1
fi

if [[ "$ASSUME_YES" != true ]]; then
  printf 'Replace this Mac\047s iTerm2 settings with the repository version? [y/N] '
  read -r reply
  case "$reply" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Cancelled."
      exit 0
      ;;
  esac
fi

BACKUP_DIR="${HOME:?}/Library/Application Support/iTerm2/Settings Backups"
mkdir -p "$BACKUP_DIR"

if defaults read "$DOMAIN" >/dev/null 2>&1; then
  TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
  BACKUP_PLIST="${BACKUP_DIR}/${DOMAIN}-${TIMESTAMP}.plist"
  defaults export "$DOMAIN" "$BACKUP_PLIST" >/dev/null
  echo "Backup created: ${BACKUP_PLIST}"
else
  echo "No existing iTerm2 preferences found; backup skipped."
fi

defaults import "$DOMAIN" "$SOURCE_PLIST"

echo "iTerm2 settings restored successfully."
echo "Start iTerm2 with: open -a iTerm"
