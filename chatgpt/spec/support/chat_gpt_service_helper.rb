module ChatGptServiceHelper
  # Construit un DatasetQuery chargé depuis le JSON de config (sans CouchDB)
  def build_dataset_query
    dataset = JSON.parse(File.read(Rails.root.join("config", "dataset.json")))
    DatasetQuery.new(dataset)
  end

  # Construit un FallbackResponderService avec des collaborateurs stubés
  def build_fallback_responder(web_search: nil, weather: nil)
    web_search ||= instance_double(WebSearchOrchestratorService, search: nil)
    weather    ||= instance_double(WeatherService, search: nil)
    FallbackResponderService.new(web_search: web_search, weather: weather)
  end

  # Construit un WikipediaService avec un IntentDetectorService minimal
  def build_wikipedia_service
    intent_detector = instance_double(
      IntentDetectorService,
      country_indicators: %w[pays état nation],
      intent_words: { cast: %w[joué jouer interprété acteur acteurs actrice] }
    )
    WikipediaService.new(intent_detector: intent_detector)
  end
end
