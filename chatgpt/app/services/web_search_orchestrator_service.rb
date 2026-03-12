require "net/http"
require "uri"
require "json"

# Proxy HTTP vers search-service.
# Toute la logique d'orchestration (Wikipedia, DuckDuckGo, Tavily, Wiktionary) est déléguée.
class WebSearchOrchestratorService
  SEARCH_SERVICE_URL = ENV.fetch("SEARCH_SERVICE_URL", "http://localhost:3003")

  # Signature compatible avec l'ancienne version (paramètres ignorés, tout est dans search-service)
  def initialize(wiktionary: nil, wikipedia: nil, duckduckgo: nil, tavily: nil, compound_resolver: nil)
  end

  def search(query)
    uri      = URI("#{SEARCH_SERVICE_URL}/search")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 3
    http.read_timeout = 30
    request  = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { query: query }.to_json
    response = http.request(request)
    return nil unless response.code == "200"

    JSON.parse(response.body)["result"]
  rescue => e
    Rails.logger.error "[WebSearchOrchestratorService] Erreur microservice : #{e.message}"
    nil
  end
end
