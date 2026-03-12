require_relative "couch_client"

class MemoryStore
  DB_NAME = "chatgpt_memory"

  VIEW_BY_SESSION = {
    "_id"   => "_design/memory",
    "views" => {
      "by_session" => {
        "map" => "function(doc) { if(doc.session_id) { emit(doc.session_id, { role: doc.role, content: doc.content }); } }"
      }
    }
  }.freeze

  def initialize
    @db = CouchClient.db(DB_NAME)
    ensure_views!
  end

  def find_by_session(session_id)
    @db.view("memory/by_session", key: session_id)["rows"].map { |r| r["value"] }
  rescue => e
    warn "[MemoryStore] Erreur find_by_session : #{e.message}"
    []
  end

  def create(session_id:, role:, content:)
    @db.save_doc({
      "session_id" => session_id,
      "role"       => role,
      "content"    => content,
      "timestamp"  => Time.now.utc.iso8601
    })
  rescue => e
    warn "[MemoryStore] Erreur create : #{e.message}"
    nil
  end

  private

  def ensure_views!
    existing = @db.get("_design/memory") rescue nil
    @db.save_doc(Marshal.load(Marshal.dump(VIEW_BY_SESSION))) if existing.nil?
  end
end
