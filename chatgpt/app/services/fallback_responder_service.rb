# Génère une réponse de fallback quand aucune entrée du dataset ne correspond.
# Priorise : météo → question factuelle (recherche web) → sentiment → défaut.
class FallbackResponderService
  POSITIVE_WORDS = %w[bien super génial parfait parfaitement cool top excellent magnifique content contente heureux heureuse formidable nickel impeccable extra chouette trop adore aime fantastique merveilleux].freeze
  NEGATIVE_WORDS = %w[mal triste nul horrible mauvais moche ennui ennuie fatigue fatigué peur stress stressé déprimé marre chiant pénible bof].freeze
  QUESTION_WORDS = %w[qui que quoi quel quelle quels quelles où comment pourquoi quand combien est-ce].freeze

  OPINION_ADJECTIVES = %w[
    beau belle beaux belles joli jolie jolis jolies moche moches
    bien mal bon bonne bons bonnes mauvais mauvaise
    grand grande grands grandes petit petite petits petites
    intéressant intéressante ennuyeux ennuyeuse
    facile difficile important importante normal normale
    vrai vraie faux fausse possible impossible
    sympa gentil gentille méchant méchante
  ].freeze

  POSITIVE_RESPONSES = [
    "Super ! Ça fait plaisir à entendre !",
    "Génial ! Content pour toi !",
    "Top ! Continue comme ça !",
    "Ça fait plaisir ! 😊"
  ].freeze

  NEGATIVE_RESPONSES = [
    "Oh, désolé d'entendre ça. Tu veux en parler ?",
    "Courage ! Ça va aller mieux.",
    "Je suis là si tu as besoin de parler.",
    "Pas facile... Qu'est-ce qui ne va pas ?"
  ].freeze

  QUESTION_RESPONSES = [
    "Bonne question ! Malheureusement je n'ai pas la réponse.",
    "Hmm, je ne suis pas sûr. Essaie de reformuler !",
    "Je ne connais pas la réponse, mais c'est intéressant comme question !"
  ].freeze

  DEFAULT_RESPONSES = [
    "Intéressant ! Dis-m'en plus.",
    "D'accord ! Quoi d'autre ?",
    "Je vois ! Continue.",
    "Ah oui ? Raconte-moi plus !",
    "C'est noté ! Autre chose ?"
  ].freeze

  def initialize(web_search:, weather:)
    @web_search = web_search
    @weather    = weather
  end

  # Accepte un UserMessage (value object) ou une String
  def call(msg)
    msg = UserMessage.new(raw: msg.to_s, session_id: nil) unless msg.is_a?(UserMessage)

    if msg.weather_related?
      weather_answer = @weather.search(msg.raw)
      return weather_answer if weather_answer
    end

    if msg.question? && !opinion_question?(msg)
      @web_search.search(msg.raw) || QUESTION_RESPONSES.sample
    elsif msg.question? && opinion_question?(msg)
      QUESTION_RESPONSES.sample
    elsif msg.normalized.any? { |w| POSITIVE_WORDS.include?(w) }
      POSITIVE_RESPONSES.sample
    elsif msg.normalized.any? { |w| NEGATIVE_WORDS.include?(w) }
      NEGATIVE_RESPONSES.sample
    else
      DEFAULT_RESPONSES.sample
    end
  end

  private

  def opinion_question?(msg)
    raw   = msg.raw.downcase
    words = msg.normalized
    has_pattern   = raw.match?(/\b(est[\s\-]ce\s+que?\b|est\s+que?\b|c\s*est\b|tu\s+trouves?\b|tu\s+penses?\b|tu\s+crois?\b|tu\s+aimes?\b)/i)
    has_adjective = words.any? { |w| OPINION_ADJECTIVES.include?(w) }
    has_pattern && has_adjective
  end
end
