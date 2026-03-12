# Orchestrateur principal.
# Toutes les responsabilités sont déléguées aux microservices :
#   - dataset-service  → matching, apprentissage, mémoire (CouchDB)
#   - nlp-service      → intent, compound phrases
#   - search-service   → Wikipedia, DuckDuckGo, Tavily, Wiktionary
#   - weather-service  → météo
class ChatGptService
  def initialize
    @compound_resolver = CompoundPhraseResolverService.new
    @dataset_query     = DatasetQuery.new
    @auto_learner      = AutoLearnerService.new(compound_resolver: @compound_resolver)
    @web_search        = WebSearchOrchestratorService.new
    @fallback          = FallbackResponderService.new(web_search: @web_search, weather: WeatherService.new)
  end

  def predict(raw_message, session_id)
    msg = UserMessage.new(raw: raw_message, session_id: session_id)
    Memory.create(session_id: session_id, role: "user", content: msg.raw)

    match = @dataset_query.find_best_match(msg.raw)

    answer = if match
      @auto_learner.learn_pending(session_id, match["answer"])
      match["answer"]
    else
      reply = @fallback.call(msg)
      @auto_learner.handle_fallback(session_id, msg, reply)
      reply
    end

    Memory.create(session_id: session_id, role: "bot", content: answer)
    answer
  end
end
