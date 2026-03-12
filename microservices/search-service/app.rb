require "sinatra"
require "sinatra/json"
require "json"

require_relative "lib/wiktionary"
require_relative "lib/wikipedia"
require_relative "lib/duckduckgo"
require_relative "lib/tavily"
require_relative "lib/orchestrator"

set :port, 3003
set :bind, "0.0.0.0"
disable :protection

TAVILY_API_KEY = ENV.fetch("TAVILY_API_KEY", "")

ORCHESTRATOR = Orchestrator.new(
  wiktionary: Wiktionary.new,
  wikipedia:  Wikipedia.new,
  duckduckgo: DuckDuckGo.new,
  tavily:     Tavily.new(api_key: TAVILY_API_KEY)
)

# ---------------------------------------------------------------------------
# POST /search
# body: { "query": "qui a créé Linux ?" }
# → { "result": "D'après Wikipedia : ..." }  ou  { "result": null }
# ---------------------------------------------------------------------------
post "/search" do
  body  = parse_body!
  query = body["query"].to_s.strip
  halt 400, json(error: "query manquante") if query.empty?

  result = ORCHESTRATOR.search(query)
  json(result: result)
end

get "/health" do
  json(status: "ok")
end

def parse_body!
  request.body.rewind
  JSON.parse(request.body.read)
rescue JSON::ParserError => e
  halt 400, json(error: "JSON invalide : #{e.message}")
end
