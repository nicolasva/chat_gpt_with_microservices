#!/bin/bash
set -e

COUCHDB_URL="${COUCHDB_URL:-http://admin:admin@127.0.0.1:5984}"
MAX_RETRIES="${COUCHDB_MAX_RETRIES:-30}"
RETRY_INTERVAL="${COUCHDB_RETRY_INTERVAL:-2}"

echo "[wait-for-couchdb] Waiting for CouchDB at ${COUCHDB_URL}..."

for i in $(seq 1 "$MAX_RETRIES"); do
  if curl -sf "${COUCHDB_URL}/_up" > /dev/null 2>&1; then
    echo "[wait-for-couchdb] CouchDB is ready (attempt $i/$MAX_RETRIES)"
    exit 0
  fi
  echo "[wait-for-couchdb] CouchDB not ready yet ($i/$MAX_RETRIES), retrying in ${RETRY_INTERVAL}s..."
  sleep "$RETRY_INTERVAL"
done

echo "[wait-for-couchdb] ERROR: CouchDB did not become ready after $MAX_RETRIES attempts"
exit 1
