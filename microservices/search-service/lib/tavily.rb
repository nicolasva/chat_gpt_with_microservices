require "net/http"
require "uri"
require "json"
require_relative "keyword_extractor"

class Tavily
  def initialize(api_key:)
    @api_key = api_key
  end

  def search(query)
    return nil if @api_key.nil? || @api_key.empty?

    keywords = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    uri              = URI("https://api.tavily.com/search")
    http             = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.open_timeout = 5
    http.read_timeout = 10

    request                  = Net::HTTP::Post.new(uri)
    request["Content-Type"]  = "application/json"
    request["Authorization"] = "Bearer #{@api_key}"
    request.body = {
      query:          keywords.join(" "),
      search_depth:   "basic",
      max_results:    3,
      include_answer: false,
      country:        "France"
    }.to_json

    response = http.request(request)
    return nil unless response.code == "200"

    results = JSON.parse(response.body)["results"]
    return nil if results.nil? || results.empty?

    content = results.first(3).map do |item|
      "#{item['title']} : #{item['content']&.gsub("\n", " ")}"
    end.join("\n")

    "Résultats Tavily : #{content}"
  rescue => e
    warn "[Tavily] Erreur : #{e.message}"
    nil
  end
end
