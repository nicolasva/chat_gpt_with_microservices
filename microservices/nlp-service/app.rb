require "sinatra"
require "sinatra/json"
require "json"

require_relative "lib/text_normalizer"
require_relative "lib/keyword_extractor"
require_relative "lib/intent_detector"
require_relative "lib/compound_resolver"

set :port, 3002
set :bind, "0.0.0.0"
disable :protection

QUESTION_WORDS = %w[qui que quoi quel quelle quels quelles où comment pourquoi quand combien est-ce].freeze
WEATHER_WORDS  = %w[temps météo meteo température temperature climat pluie soleil neige vent chaud froid].freeze

# Initialisation asynchrone : l'enrichissement Wiktionary peut prendre 30-60s.
# Sinatra démarre immédiatement ; /health retourne 503 jusqu'à ce que ce soit prêt.
$nlp_ready        = false
$intent_detector  = nil
$compound_resolver = nil

Thread.new do
  $intent_detector   = IntentDetector.new
  $compound_resolver = CompoundResolver.new
  $nlp_ready         = true
  warn "[nlp-service] Prêt."
rescue => e
  warn "[nlp-service] Erreur init : #{e.message} — démarrage en mode dégradé"
  $intent_detector   ||= IntentDetector.new rescue nil
  $compound_resolver ||= CompoundResolver.new rescue nil
  $nlp_ready = true
end

# ---------------------------------------------------------------------------

post "/detect_intent" do
  halt 503, json(error: "démarrage en cours") unless $nlp_ready
  body   = parse_body!
  words  = Array(body["words"])
  intent = $intent_detector.detect(words)
  json(intent: intent)
end

post "/find_best_section" do
  halt 503, json(error: "démarrage en cours") unless $nlp_ready
  body      = parse_body!
  full_text = body["full_text"].to_s
  query     = body["query"].to_s
  section   = $intent_detector.find_best_section(full_text, query)
  json(section: section)
end

post "/resolve_compound" do
  halt 503, json(error: "démarrage en cours") unless $nlp_ready
  body     = parse_body!
  text     = body["text"].to_s
  resolved = $compound_resolver.resolve(text)
  json(resolved: resolved)
end

post "/analyze" do
  halt 503, json(error: "démarrage en cours") unless $nlp_ready
  body    = parse_body!
  message = body["message"].to_s

  normalized  = TextNormalizer.normalize(message)
  keywords    = KeywordExtractor.extract(message)
  intent      = $intent_detector.detect(normalized)
  is_question = message.include?("?") || normalized.any? { |w| QUESTION_WORDS.include?(w) }
  is_weather  = normalized.any? { |w| WEATHER_WORDS.include?(w) }

  json(
    normalized:  normalized,
    keywords:    keywords,
    intent:      intent,
    is_question: is_question,
    is_weather:  is_weather
  )
end

# 200 = prêt, 503 = démarrage en cours (Docker attend le 200 pour passer healthy)
get "/health" do
  if $nlp_ready
    json(status: "ok")
  else
    status 503
    json(status: "starting")
  end
end

# ---------------------------------------------------------------------------

def parse_body!
  request.body.rewind
  JSON.parse(request.body.read)
rescue JSON::ParserError => e
  halt 400, json(error: "JSON invalide : #{e.message}")
end
