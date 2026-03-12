require "sinatra"
require "sinatra/json"
require "json"

require_relative "lib/dataset_store"
require_relative "lib/memory_store"

set :port, 3004
set :bind, "0.0.0.0"
disable :protection

DATASET = DatasetStore.new
MEMORY  = MemoryStore.new

# Seed + cleanup au démarrage
DATASET.seed_if_empty!
DATASET.cleanup_web_entries!

# ── DATASET ────────────────────────────────────────────────────────────────

# POST /dataset/match   body: { "question": "..." }
# → { "doc": { question, answer, _id, _rev } } ou { "doc": null }
post "/dataset/match" do
  body = parse_body!
  doc  = DATASET.find_best_match(body["question"].to_s)
  json(doc: doc)
end

# POST /dataset   body: { "question": "...", "answer": "..." }
# → doc créé (201) ou 409 si déjà existant
post "/dataset" do
  body = parse_body!
  halt 400, json(error: "question et answer requis") unless body["question"] && body["answer"]

  if DATASET.exists?(body["question"])
    halt 409, json(error: "question déjà connue")
  end

  doc = DATASET.create({ "question" => body["question"], "answer" => body["answer"] })
  status 201
  json(doc: doc)
end

# DELETE /dataset/:id   body: { "rev": "..." }
delete "/dataset/:id" do
  body = parse_body!
  halt 400, json(error: "rev requis") unless body["rev"]

  DATASET.delete(params[:id], body["rev"])
  json(status: "deleted")
end

# GET /dataset/exists?question=...
get "/dataset/exists" do
  question = params[:question].to_s
  json(exists: DATASET.exists?(question))
end

# ── MEMORY ─────────────────────────────────────────────────────────────────

# GET /memory/:session_id
# → [{ role, content }, ...]
get "/memory/:session_id" do
  messages = MEMORY.find_by_session(params[:session_id])
  json(messages: messages)
end

# POST /memory   body: { "session_id": "...", "role": "user|bot", "content": "..." }
post "/memory" do
  body = parse_body!
  halt 400, json(error: "session_id, role et content requis") unless body["session_id"] && body["role"] && body["content"]

  MEMORY.create(session_id: body["session_id"], role: body["role"], content: body["content"])
  status 201
  json(status: "created")
end

# ── HEALTH ─────────────────────────────────────────────────────────────────

get "/health" do
  json(status: "ok")
end

# ── HELPERS ────────────────────────────────────────────────────────────────

def parse_body!
  request.body.rewind
  JSON.parse(request.body.read)
rescue JSON::ParserError => e
  halt 400, json(error: "JSON invalide : #{e.message}")
end
