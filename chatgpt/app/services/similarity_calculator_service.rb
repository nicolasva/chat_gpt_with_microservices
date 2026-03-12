module SimilarityCalculatorService
  MATCHING_STOP_WORDS = %w[
    je tu il elle on nous vous ils elles
    le la les l un une des de du au aux en
    a à est es et ou où ni ne pas
    me te se ce ça sa son ses mon ma mes ton ta tes
    qui que quoi dont quel quelle quels quelles
    film films acteur acteurs actrice actrices
    connais sais dire dis peux peut faire fait
    sont pour par sur dans avec sans vers chez entre contre
    comment pourquoi quand combien
    être avoir etre fait font va vont sera serait
    faut falloir prendre donner utiliser
    aussi très bien plus moins tout tous toute toutes
    cette cet ces autre autres encore même
    médicament médicaments traitement traitements remède remèdes
    soigner guérir prendre soulager traiter
  ].freeze

  def self.normalize_for_matching(text)
    TextNormalizerService.normalize(text).reject { |w| MATCHING_STOP_WORDS.include?(w) || w.length < 2 }
  end

  def self.jaccard(words_a, words_b)
    return 0.0 if words_a.empty? || words_b.empty?
    intersection = (words_a & words_b).size.to_f
    union        = (words_a | words_b).size.to_f
    union.zero? ? 0.0 : intersection / union
  end

  def self.stem_match?(word_a, word_b)
    return true if word_a == word_b

    a = TextNormalizerService.strip_accents(word_a)
    b = TextNormalizerService.strip_accents(word_b)
    return true if a == b

    return true if a + "s" == b || b + "s" == a
    return true if a + "es" == b || b + "es" == a
    return true if a + "x" == b || b + "x" == a
    return true if a.sub(/aux\z/, "al") == b || b.sub(/aux\z/, "al") == a

    a_stem = a.sub(/(er|ee?s?|ant|ent)\z/, "")
    b_stem = b.sub(/(er|ee?s?|ant|ent)\z/, "")
    return true if a_stem == b_stem && a_stem.length >= 3

    false
  end

  def self.stem_match_count(search_words, title_words)
    search_words.count { |sw| title_words.any? { |tw| stem_match?(sw, tw) } }
  end

  def self.levenshtein_close?(a, b)
    return true if a == b
    return false if (a.length - b.length).abs > 2

    max_len = [a.length, b.length].max
    common  = 0
    [a.length, b.length].min.times { |i| common += 1 if a[i] == b[i] }
    common.to_f / max_len > 0.7
  end
end
