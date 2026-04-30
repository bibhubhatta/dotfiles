#!/bin/bash
set -euo pipefail

# Enable the Vicinae launcher daemon as a user service so it starts with the
# graphical session. The unit ships with the `vicinae` package; we just flip
# it on. Re-runs of `enable --now` are no-ops, so this is safe to repeat.

if ! command -v vicinae >/dev/null 2>&1; then
  echo "vicinae not installed; skipping service enablement." >&2
  exit 0
fi

if ! systemctl --user list-unit-files vicinae.service >/dev/null 2>&1; then
  echo "vicinae.service unit not found; skipping." >&2
  exit 0
fi

systemctl --user enable --now vicinae.service
