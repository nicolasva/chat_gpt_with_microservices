require "net/http"
require "uri"
require "json"
require_relative "similarity_calculator"

class Wiktionary
  BASE_URL = "https://fr.wiktionary.org/w/api.php"

  def find_synonyms(word)
    encoded  = URI.encode_www_form_component(word.downcase)
    uri      = URI("#{BASE_URL}?action=parse&page=#{encoded}&prop=wikitext&format=json")
    response = Net::HTTP.get_response(uri)
    return [] unless response.code == "200"

    wikitext    = JSON.parse(response.body).dig("parse", "wikitext", "*")
    return [] if wikitext.nil?

    synonyms    = []
    in_synonyms = false
    wikitext.split("\n").each do |line|
      if line.include?("{{S|synonymes")
        in_synonyms = true
        next
      end
      if in_synonyms
        break if line.match?(/\{\{S\|/)
        m = line.match(/\[\[([^\]|#]+)/)
        synonyms << m[1].strip.downcase if m && !m[1].strip.empty?
      end
    end
    synonyms.first(5)
  rescue => e
    warn "[Wiktionary] Erreur synonymes '#{word}' : #{e.message}"
    []
  end

  def definition(word)
    encoded  = URI.encode_www_form_component(word.downcase)
    uri      = URI("#{BASE_URL}?action=parse&page=#{encoded}&prop=wikitext&format=json")
    response = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    wikitext = JSON.parse(response.body).dig("parse", "wikitext", "*")
    return nil if wikitext.nil?

    wikitext.split("\n").each do |line|
      next unless line.match?(/\A#[^#*:]/)
      clean = line.sub(/\A#+\s*/, "")
                  .gsub(/\{\{[^}]*\}\}/, "")
                  .gsub(/\[\[(?:[^|\]]*\|)?([^\]]*)\]\]/, '\1')
                  .gsub(/'{2,}/, "").strip
      return clean unless clean.empty?
    end
    nil
  rescue => e
    warn "[Wiktionary] Erreur définition '#{word}' : #{e.message}"
    nil
  end

  def correct_spelling(word)
    encoded  = URI.encode_www_form_component(word.downcase)
    uri      = URI("#{BASE_URL}?action=query&list=search&srsearch=#{encoded}&srlimit=1&format=json")
    response = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    data       = JSON.parse(response.body)
    suggestion = data.dig("query", "searchinfo", "suggestion")
    return suggestion if suggestion && suggestion != word.downcase

    results = data.dig("query", "search")
    if results && !results.empty?
      title = results.first["title"].downcase
      return title if title != word.downcase && SimilarityCalculator.levenshtein_close?(word.downcase, title)
    end
    nil
  rescue => e
    warn "[Wiktionary] Erreur correction '#{word}' : #{e.message}"
    nil
  end
end
