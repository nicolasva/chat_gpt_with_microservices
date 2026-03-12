require "yaml"
require_relative "similarity_calculator"

# Détection d'intention locale (sans enrichissement Wiktionary).
# Utilisée uniquement pour orienter la stratégie de recherche Wikipedia.
module LocalIntentDetector
  KEYWORDS_PATH = File.join(__dir__, "..", "config", "intent_keywords.yml")

  def self.config
    @config ||= begin
      data = YAML.load_file(KEYWORDS_PATH)
      intents = {}
      (data["intents"] || {}).each do |name, d|
        words = ((d["seeds"] || []) + (d["extra_words"] || [])).map(&:downcase).uniq
        intents[name.to_sym] = words
      end
      {
        intent_words:       intents,
        country_indicators: (data["country_indicators"] || []).map(&:downcase)
      }
    end
  end

  def self.country_indicators
    config[:country_indicators]
  end

  def self.cast_words
    config[:intent_words][:cast] || []
  end
end
