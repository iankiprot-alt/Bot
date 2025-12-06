
#!/usr/bin/env bash
set -e

# start.sh - prepares runtime directories and optionally restores auth from AUTH_TAR_B64
# Usage:
#   - To restore auth from a base64 tar.gz: export AUTH_TAR_B64="$(cat auth.b64)"
#   - Then run: npm start
#
# The script will:
#  - decode AUTH_TAR_B64 (if provided) into ./auth
#  - create necessary media directories
#  - exit (the package.json start script runs node index.js afterwards)

# Helper to decode base64 into /tmp/auth.tar.gz using available base64 command
_decode_base64_to_file() {
  local b64="$1"
  local out="$2"

  # Try GNU base64 / BSD base64 / openssl fallback
  if command -v base64 >/dev/null 2>&1; then
    # Try GNU-style (-d). If it fails, try BSD-style (-D), then plain base64 piped through openssl as fallback.
    if echo "$b64" | base64 -d > "$out" 2>/dev/null; then
      return 0
    fi
    if echo "$b64" | base64 -D > "$out" 2>/dev/null; then
      return 0
    fi
  fi

  if command -v openssl >/dev/null 2>&1; then
    if printf '%s' "$b64" | openssl base64 -d -out "$out" 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

if [ ! -z "${AUTH_TAR_B64:-}" ]; then
  echo "[start.sh] Restoring auth from AUTH_TAR_B64..."
  mkdir -p ./auth
  TMP_TAR="/tmp/auth.tar.gz"
  if _decode_base64_to_file "$AUTH_TAR_B64" "$TMP_TAR"; then
    if tar -xzf "$TMP_TAR" -C ./auth 2>/dev/null; then
      echo "[start.sh] Auth restored to ./auth"
      rm -f "$TMP_TAR"
    else
      echo "[start.sh] Failed to extract $TMP_TAR into ./auth" >&2
      rm -f "$TMP_TAR"
      # continue; maybe auth is malformed
    fi
  else
    echo "[start.sh] Failed to decode AUTH_TAR_B64. Ensure it is a base64-encoded tar.gz" >&2
  fi
fi

# Ensure media directories exist
mkdir -p ./media \
         ./media/statuses/images \
         ./media/statuses/videos \
         ./media/downloads \
         ./media/yt \
         ./media/viewonce

# Ensure auth dir exists (Baileys will create files inside it on first run)
mkdir -p ./auth

echo "[start.sh] Ready. Starting node next (npm start will run node index.js)."
exit 0
