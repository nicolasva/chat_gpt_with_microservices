require "net/http"
require "uri"
require "json"

# Adaptateur HTTP vers nlp-service.
# Garde un fallback local minimaliste si le microservice est indisponible.
class IntentDetectorService
  NLP_SERVICE_URL = ENV.fetch("NLP_SERVICE_URL", "http://localhost:3002")

  # Conservés pour rétrocompatibilité (WikipediaService les utilise encore)
  attr_reader :intent_words, :intent_targets, :country_indicators

  def initialize(wiktionary_service: nil)
    # wiktionary_service conservé pour compatibilité mais non utilisé ici
    @intent_words       = {}
    @intent_targets     = {}
    @country_indicators = []
  end

  def detect(query_words)
    uri      = URI("#{NLP_SERVICE_URL}/detect_intent")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 5
    request  = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { words: query_words }.to_json
    response = http.request(request)
    return nil unless response.code == "200"

    result = JSON.parse(response.body)
    result["intent"]&.to_sym
  rescue => e
    Rails.logger.error "[IntentDetectorService] Erreur microservice : #{e.message}"
    nil
  end

  def find_best_section(full_text, query)
    uri      = URI("#{NLP_SERVICE_URL}/find_best_section")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 10
    request  = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { full_text: full_text, query: query }.to_json
    response = http.request(request)
    return full_text.split(/\n\n+==/).first.to_s.strip unless response.code == "200"

    JSON.parse(response.body)["section"].to_s
  rescue => e
    Rails.logger.error "[IntentDetectorService] Erreur find_best_section : #{e.message}"
    full_text.split(/\n\n+==/).first.to_s.strip
  end
end
