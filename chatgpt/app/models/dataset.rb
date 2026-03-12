# Proxy vers dataset-service — plus de dépendance directe à CouchDB.
class Dataset
  WEB_SOURCES = ["D'après Wikipedia", "D'après DuckDuckGo", "Résultats DuckDuckGo", "Résultats Tavily"].freeze

  class << self
    def create(attrs)
      result = DatasetServiceClient.post("/dataset", attrs)
      result&.dig("doc") || attrs
    end

    def delete(doc)
      return false unless doc["_id"] && doc["_rev"]
      DatasetServiceClient.delete("/dataset/#{doc['_id']}", { rev: doc["_rev"] })
    end
  end
end
