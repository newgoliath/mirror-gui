#!/bin/bash
set -e

APP_USER="default"
APP_DATA="/app/data"
DIRS="$APP_DATA/configs $APP_DATA/operations $APP_DATA/logs $APP_DATA/cache $APP_DATA/mirrors/default $APP_DATA/catalog-data"

for d in $DIRS; do
    mkdir -p "$d"
done

chown -R "${APP_USER}:0" "$APP_DATA"
chmod -R 775 "$APP_DATA"

if [ -n "${OC_MIRROR_AUTHFILE:-}" ]; then
    SEARCH_PATHS="$OC_MIRROR_AUTHFILE"
else
    SEARCH_PATHS="/run/secrets/pull-secret.json /run/secrets/pull-secret /app/pull-secret.json $APP_DATA/.pull-secret.json"
fi

for candidate in $SEARCH_PATHS; do
    if [ -f "$candidate" ] && [ -s "$candidate" ]; then
        chown "${APP_USER}:0" "$candidate" 2>/dev/null || true
        chmod 664 "$candidate" 2>/dev/null || true
        echo "[ENTRYPOINT] Pull secret found at: $candidate"
        break
    fi
done

if su -s /bin/sh "$APP_USER" -c "test -w $APP_DATA/configs"; then
    echo "[ENTRYPOINT] Permissions OK"
else
    echo "[ENTRYPOINT] ERROR: $APP_DATA/configs not writable by ${APP_USER} user"
    echo "[ENTRYPOINT] Host fix: sudo chown -R 1001:0 data/ && sudo chmod -R 775 data/"
    exit 1
fi

exec runuser -u "$APP_USER" -- "$@"
