require "net/http"
require "uri"
require "json"

# Client minimal Wiktionary (fr) pour enrichir les mots-clés d'intention
# et résoudre les expressions composées.
module WiktionaryClient
  BASE_URL = "https://fr.wiktionary.org/w/api.php"

  def self.find_synonyms(word)
    params = {
      action:  "parse",
      page:    word,
      prop:    "wikitext",
      format:  "json"
    }
    body = get(params)
    return [] unless body

    wikitext = body.dig("parse", "wikitext", "*").to_s
    extract_synonyms(wikitext)
  rescue => e
    warn "[WiktionaryClient] Erreur synonymes '#{word}' : #{e.message}"
    []
  end

  def self.definition(word)
    params = {
      action:  "query",
      titles:  word,
      prop:    "extracts",
      exintro: true,
      format:  "json"
    }
    body = get(params)
    return nil unless body

    pages = body.dig("query", "pages") || {}
    pages.values.first&.dig("extract")
  rescue => e
    warn "[WiktionaryClient] Erreur définition '#{word}' : #{e.message}"
    nil
  end

  private

  def self.get(params)
    uri       = URI(BASE_URL)
    uri.query = URI.encode_www_form(params)
    http      = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 8
    response  = http.request(Net::HTTP::Get.new(uri))
    return nil unless response.code == "200"

    JSON.parse(response.body)
  end

  def self.extract_synonyms(wikitext)
    synonyms = []
    in_syn   = false
    wikitext.each_line do |line|
      if line.match?(/synonymes?/i)
        in_syn = true
        next
      end
      break if in_syn && line.match?(/\A==/)
      next unless in_syn

      line.scan(/\[\[([^\[\]|]+)(?:\|[^\]]+)?\]\]/) { synonyms << $1.downcase.strip }
      line.scan(/\*\s*([a-zàâäéèêëîïôöùûüÿç][^,\n*#]+)/) { synonyms << $1.strip.downcase }
    end
    synonyms.uniq.reject { |s| s.include?("[[") || s.length > 30 }.first(5)
  end
end
