require "net/http"
require "uri"
require "json"

# Adaptateur HTTP vers nlp-service.
# Fallback : retourne le texte original si le microservice est indisponible.
class CompoundPhraseResolverService
  NLP_SERVICE_URL = ENV.fetch("NLP_SERVICE_URL", "http://localhost:3002")

  def initialize(wiktionary_service: nil)
    # wiktionary_service conservé pour compatibilité mais non utilisé ici
  end

  def resolve(text)
    uri      = URI("#{NLP_SERVICE_URL}/resolve_compound")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 10
    request  = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { text: text }.to_json
    response = http.request(request)
    return text unless response.code == "200"

    JSON.parse(response.body)["resolved"].to_s
  rescue => e
    Rails.logger.error "[CompoundPhraseResolverService] Erreur microservice : #{e.message}"
    text
  end
end
