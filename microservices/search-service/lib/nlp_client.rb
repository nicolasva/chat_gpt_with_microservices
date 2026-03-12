require "net/http"
require "uri"
require "json"

# Client HTTP vers nlp-service pour find_best_section (enrichi avec intent + Wiktionary).
module NlpClient
  NLP_SERVICE_URL = ENV.fetch("NLP_SERVICE_URL", "http://localhost:3002")

  def self.find_best_section(full_text, query)
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
    warn "[NlpClient] Erreur find_best_section : #{e.message}"
    full_text.split(/\n\n+==/).first.to_s.strip
  end
end
