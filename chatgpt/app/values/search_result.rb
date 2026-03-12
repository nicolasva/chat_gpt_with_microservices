# Value Object représentant le résultat d'une recherche externe.
# Immuable, comparable par valeur (source + content).
# Encapsule les comportements liés à la qualification du résultat.
class SearchResult
  WEB_SOURCES = ["Wikipedia", "DuckDuckGo", "Tavily"].freeze

  attr_reader :source, :content

  def initialize(source:, content:)
    @source  = source.to_s
    @content = content.to_s
    freeze
  end

  # --- Égalité par valeur (DDD) ---

  def ==(other)
    other.is_a?(SearchResult) && source == other.source && content == other.content
  end

  alias eql? ==

  def hash
    [source, content].hash
  end

  # --- Comportements métier ---

  def present?
    !content.empty?
  end

  def web_result?
    WEB_SOURCES.any? { |s| source.include?(s) }
  end

  # Vérifie que le contenu est suffisamment long pour être utile
  def substantial?
    present? && content.length > source.length + 15
  end

  def to_s
    source.start_with?("Résultats") ? "#{source} :\n#{content}" : "D'après #{source} : #{content}"
  end

  # --- Factories sémantiques ---

  def self.from_wikipedia(content)
    new(source: "Wikipedia", content: content.to_s)
  end

  def self.from_duckduckgo(content)
    new(source: "DuckDuckGo", content: content.to_s)
  end

  # Pour Tavily, le content est déjà une liste formatée de résultats
  def self.from_tavily(content)
    new(source: "Résultats Tavily", content: content.to_s)
  end

  def self.none
    new(source: "", content: "")
  end
end
