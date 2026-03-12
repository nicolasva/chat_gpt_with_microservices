require_relative "text_normalizer"

module SimilarityCalculator
  def self.stem_match?(word_a, word_b)
    return true if word_a == word_b

    a = TextNormalizer.strip_accents(word_a)
    b = TextNormalizer.strip_accents(word_b)
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
end
