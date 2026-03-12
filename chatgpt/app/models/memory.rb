# Proxy vers dataset-service — plus de dépendance directe à CouchDB.
class Memory
  class << self
    def find_by_session(session_id)
      result = DatasetServiceClient.get("/memory/#{session_id}")
      result&.dig("messages") || []
    end

    def create(session_id:, role:, content:)
      DatasetServiceClient.post("/memory", { session_id: session_id, role: role, content: content })
    end
  end
end
