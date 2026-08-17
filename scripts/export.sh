#!/bin/bash

set -euo pipefail

DOMAIN="com.googlecode.iterm2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DESTINATION="${REPO_DIR}/settings/${DOMAIN}.plist"
SANITIZER="${SCRIPT_DIR}/sanitize_plist.py"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: this exporter only supports macOS." >&2
  exit 1
fi

for command_name in defaults plutil python3 mktemp pgrep; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: required command not found: ${command_name}" >&2
    exit 1
  fi
done

if [[ ! -f "$SANITIZER" ]]; then
  echo "Error: sanitizer not found: ${SANITIZER}" >&2
  exit 1
fi

if pgrep -x iTerm2 >/dev/null 2>&1; then
  echo "Note: iTerm2 is running; preferences currently registered with macOS will be exported."
fi

TEMP_ROOT="${TMPDIR:-/tmp}"
TEMP_PLIST="$(mktemp "${TEMP_ROOT%/}/iterm2-settings.XXXXXX")"

cleanup() {
  if [[ -n "${TEMP_PLIST:-}" && -f "$TEMP_PLIST" ]]; then
    case "$TEMP_PLIST" in
      "${TEMP_ROOT%/}"/iterm2-settings.*)
        rm -f -- "$TEMP_PLIST"
        ;;
      *)
        echo "Warning: refusing to clean unexpected temp path: ${TEMP_PLIST}" >&2
        ;;
    esac
  fi
}
trap cleanup EXIT

mkdir -p "$(dirname "$DESTINATION")"
defaults export "$DOMAIN" "$TEMP_PLIST" >/dev/null
python3 "$SANITIZER" "$TEMP_PLIST" "$DESTINATION"
plutil -lint "$DESTINATION" >/dev/null

echo "Exported sanitized iTerm2 settings to: ${DESTINATION}"
echo "Review before publishing: git diff -- settings/${DOMAIN}.plist"
