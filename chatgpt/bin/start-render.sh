#!/bin/bash
set -e

# ---- Start CouchDB ----
echo "[render] Starting CouchDB..."

# Configure CouchDB data directory
mkdir -p /opt/couchdb/etc/local.d
cat > /opt/couchdb/etc/local.d/render.ini << 'INIEOF'
[couchdb]
database_dir = /rails/couchdb-data
view_index_dir = /rails/couchdb-data
single_node = true

[chttpd]
port = 5984
bind_address = 127.0.0.1

[admins]
admin = admin

[log]
level = warning
INIEOF
chown -R couchdb:couchdb /opt/couchdb/etc/local.d /rails/couchdb-data

# Start CouchDB as couchdb user in background
su -s /bin/bash -c "/opt/couchdb/bin/couchdb" couchdb &
COUCH_PID=$!

# Wait for CouchDB to be ready (max 30 seconds)
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:5984/_up > /dev/null 2>&1; then
    echo "[render] CouchDB ready (PID: $COUCH_PID, attempt $i/30)"
    break
  fi
  echo "[render] Waiting for CouchDB... ($i/30)"
  sleep 1
done

if ! curl -sf http://127.0.0.1:5984/_up > /dev/null 2>&1; then
  echo "[render] ERROR: CouchDB failed to start"
  exit 1
fi

# Initialize single-node cluster + system databases
echo "[render] Configuring CouchDB single-node..."
curl -s -X POST http://admin:admin@127.0.0.1:5984/_cluster_setup \
  -H "Content-Type: application/json" \
  -d '{"action":"enable_single_node","username":"admin","password":"admin","bind_address":"127.0.0.1","port":5984}' || true

for db in _users _replicator _global_changes; do
  curl -s -X PUT "http://admin:admin@127.0.0.1:5984/$db" > /dev/null 2>&1 || true
done
echo "[render] CouchDB configured"

# ---- Initialize Rails databases ----
echo "[render] Initializing app databases..."
bundle exec rake couchdb:init 2>/dev/null || true

# ---- Enable jemalloc ----
if [ -z "${LD_PRELOAD+x}" ]; then
  LD_PRELOAD=$(find /usr/lib -name libjemalloc.so.2 -print -quit)
  export LD_PRELOAD
fi

# ---- Start Rails via Thruster + Puma ----
echo "[render] Starting Rails on port ${PORT:-10000}..."
exec ./bin/thrust ./bin/rails server -p "${PORT:-10000}" -b 0.0.0.0
