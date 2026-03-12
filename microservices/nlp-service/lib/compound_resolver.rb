require "yaml"
require "fileutils"
require_relative "keyword_extractor"
require_relative "wiktionary_client"

class CompoundResolver
  CACHE_PATH = File.join(__dir__, "..", "tmp", "compound_phrases_cache.yml")

  COMPOUND_PATTERNS = [
    /\b(maux?\s+(?:de|du|des|au|aux|à\s+la|à\s+l)\s+\w+)/i,
    /\b(coup\s+de\s+\w+)/i,
    /\b(rhume\s+des?\s+\w+)/i,
    /\b(crise\s+\w+)/i,
    /\b(arrêt\s+\w+)/i,
    /\b(tension\s+\w+)/i,
    /\b(pression\s+\w+)/i,
    /\b(nez\s+(?:bouché|qui\s+coule))/i,
    /\b(brûlures?\s+d\s*['']\s*estomac)/i,
  ].freeze

  def initialize
    load_cache
  end

  def resolve(text)
    result = text.downcase
    COMPOUND_PATTERNS.each do |pattern|
      result = result.gsub(pattern) { |match| resolve_phrase(match.strip.downcase) }
    end
    result
  end

  private

  def resolve_phrase(phrase)
    return @cache[phrase] if @cache.key?(phrase)

    synonyms = WiktionaryClient.find_synonyms(phrase)
    if synonyms.any?
      cache_and_return(phrase, synonyms.first, "synonyme")
      return @cache[phrase]
    end

    definition = WiktionaryClient.definition(phrase)
    if definition
      def_keywords = KeywordExtractor.extract(definition).first(1)
      if def_keywords.any?
        cache_and_return(phrase, def_keywords.first, "définition")
        return @cache[phrase]
      end
    end

    warn "[CompoundResolver] Expression non résolue : '#{phrase}'"
    @cache[phrase] = phrase
    save_cache
    phrase
  rescue => e
    warn "[CompoundResolver] Erreur '#{phrase}' : #{e.message}"
    phrase
  end

  def cache_and_return(phrase, replacement, source)
    warn "[CompoundResolver] '#{phrase}' → '#{replacement}' (#{source})"
    @cache[phrase] = replacement
    save_cache
  end

  def load_cache
    if File.exist?(CACHE_PATH)
      @cache = YAML.load_file(CACHE_PATH) || {}
    else
      @cache = {}
    end
  end

  def save_cache
    FileUtils.mkdir_p(File.dirname(CACHE_PATH))
    File.write(CACHE_PATH, @cache.to_yaml)
  end
end
