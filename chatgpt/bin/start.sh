#!/bin/bash
set -e

# ---- Configuration CouchDB ----
COUCHDB_DIR="/app/.apt/opt/couchdb"

if [ -d "$COUCHDB_DIR" ]; then
  echo "[start.sh] CouchDB trouvé dans $COUCHDB_DIR"

  # Créer le répertoire de données
  mkdir -p /app/couchdb-data

  # Configuration locale CouchDB
  mkdir -p "$COUCHDB_DIR/etc/local.d"
  cat > "$COUCHDB_DIR/etc/local.d/heroku.ini" << 'INIEOF'
[couchdb]
database_dir = /app/couchdb-data
view_index_dir = /app/couchdb-data

[chttpd]
port = 5984
bind_address = 127.0.0.1

[admins]
admin = admin
INIEOF

  # Variables d'environnement pour CouchDB
  export ERL_FLAGS="-couch_ini $COUCHDB_DIR/etc/default.ini $COUCHDB_DIR/etc/local.ini $COUCHDB_DIR/etc/local.d/heroku.ini"

  # Démarrer CouchDB en arrière-plan
  echo "[start.sh] Démarrage de CouchDB..."
  "$COUCHDB_DIR/bin/couchdb" &
  COUCH_PID=$!

  # Attendre que CouchDB soit prêt (max 15 secondes)
  for i in $(seq 1 15); do
    if curl -s http://127.0.0.1:5984/ > /dev/null 2>&1; then
      echo "[start.sh] CouchDB démarré avec succès (PID: $COUCH_PID)"
      break
    fi
    echo "[start.sh] En attente de CouchDB... ($i/15)"
    sleep 1
  done

  if ! curl -s http://127.0.0.1:5984/ > /dev/null 2>&1; then
    echo "[start.sh] ATTENTION: CouchDB n'a pas démarré, l'app continuera sans"
  else
    # Initialiser CouchDB en mode single-node et créer les bases système
    echo "[start.sh] Configuration single-node CouchDB..."
    curl -s -X POST http://admin:admin@127.0.0.1:5984/_cluster_setup \
      -H "Content-Type: application/json" \
      -d '{"action":"enable_single_node","username":"admin","password":"admin","bind_address":"127.0.0.1","port":5984}' || true

    # Créer les bases système nécessaires
    for db in _users _replicator _global_changes; do
      curl -s -X PUT "http://admin:admin@127.0.0.1:5984/$db" > /dev/null 2>&1 || true
      echo "[start.sh] Base $db créée"
    done

    echo "[start.sh] CouchDB configuré avec succès"
  fi
else
  echo "[start.sh] ATTENTION: CouchDB non trouvé dans $COUCHDB_DIR"
fi

# ---- Démarrer Puma ----
echo "[start.sh] Démarrage de Puma..."
exec bundle exec puma -C config/puma.rb
