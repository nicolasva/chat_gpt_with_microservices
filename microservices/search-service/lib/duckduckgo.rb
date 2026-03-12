require "net/http"
require "uri"
require "json"
require_relative "keyword_extractor"

class DuckDuckGo
  def search_api(query)
    keywords    = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    search_term = URI.encode_www_form_component(keywords.join(" "))
    uri         = URI("https://api.duckduckgo.com/?q=#{search_term}&format=json&no_html=1&skip_disambig=1&lang=fr")
    response    = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    data     = JSON.parse(response.body)
    abstract = data["AbstractText"]
    return "D'après DuckDuckGo : #{abstract}" if abstract && !abstract.empty?

    answer = data["Answer"]
    return "D'après DuckDuckGo : #{answer}" if answer && !answer.empty?

    topics      = data["RelatedTopics"]
    first_topic = topics&.first
    if first_topic.is_a?(Hash) && first_topic["Text"] && !first_topic["Text"].empty?
      return "D'après DuckDuckGo : #{first_topic["Text"]}"
    end

    nil
  rescue => e
    warn "[DuckDuckGo] Erreur API : #{e.message}"
    nil
  end

  def search_web(query)
    keywords    = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    search_term = URI.encode_www_form_component(keywords.join(" "))
    uri         = URI("https://html.duckduckgo.com/html/?q=#{search_term}")

    http              = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.open_timeout = 5
    http.read_timeout = 10

    request               = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    response = http.request(request)
    return nil unless response.code == "200"

    html = response.body
    return nil if html.include?("anomaly-modal") || html.include?("captcha")

    results = []
    html.scan(/<a rel="nofollow" class="result__a" href="[^"]*">(.*?)<\/a>/) do |match|
      title = match[0].gsub(/<[^>]*>/, "").gsub("&amp;", "&").gsub("&#x27;", "'").gsub("&quot;", '"').strip
      results << title unless title.empty?
    end

    return nil if results.empty?
    "Résultats DuckDuckGo :\n#{results.first(3).join("\n")}"
  rescue => e
    warn "[DuckDuckGo] Erreur Web : #{e.message}"
    nil
  end
end
