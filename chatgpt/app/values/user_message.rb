# Value Object représentant le message d'un utilisateur dans une session.
# Immuable, comparable par valeur (raw + session_id).
# Encapsule les comportements liés à l'analyse du message (question, météo, mots-clés).
class UserMessage
  attr_reader :raw, :session_id

  def initialize(raw:, session_id:)
    @raw        = raw.to_s.strip
    @session_id = session_id
    @normalized = TextNormalizerService.normalize(@raw)
    @keywords   = KeywordExtractorService.extract(@raw)
    freeze
  end

  # --- Égalité par valeur (DDD) ---

  def ==(other)
    other.is_a?(UserMessage) && raw == other.raw && session_id == other.session_id
  end

  alias eql? ==

  def hash
    [raw, session_id].hash
  end

  # --- Comportements métier ---

  attr_reader :normalized, :keywords

  def question?
    raw.include?("?") || normalized.any? { |w| QUESTION_WORDS.include?(w) }
  end

  def weather_related?
    normalized.any? { |w| WeatherService::WEATHER_WORDS.include?(w) }
  end

  def to_s
    raw
  end

  private

  QUESTION_WORDS = %w[qui que quoi quel quelle quels quelles où comment pourquoi quand combien est-ce].freeze
end
