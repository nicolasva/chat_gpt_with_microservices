require_relative "keyword_extractor"

class Orchestrator
  def initialize(wiktionary:, wikipedia:, duckduckgo:, tavily:)
    @wiktionary  = wiktionary
    @wikipedia   = wikipedia
    @duckduckgo  = duckduckgo
    @tavily      = tavily
  end

  def search(query)
    result = search_direct(query)
    return result if result

    keywords = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    result = search_with_synonyms(query, keywords)
    return result if result && @wikipedia.relevant?(result, query)

    result = search_with_definitions(query, keywords)
    return result if result && @wikipedia.relevant?(result, query)

    result = search_with_spelling_correction(query, keywords)
    return result if result && @wikipedia.relevant?(result, query)

    extract = @wikipedia.wiki_search_individual("fr", keywords, query)
    if extract
      full_result = "D'après Wikipedia : #{extract}"
      return full_result if @wikipedia.relevant?(full_result, query)
    end

    nil
  rescue => e
    warn "[Orchestrator] Erreur : #{e.message}"
    nil
  end

  private

  def search_direct(query)
    @tavily.search(query) || @duckduckgo.search_api(query) || @wikipedia.search(query) || @duckduckgo.search_web(query)
  rescue => e
    warn "[Orchestrator] Erreur directe : #{e.message}"
    nil
  end

  def search_relaxed(query)
    @tavily.search(query) || @duckduckgo.search_api(query) || @wikipedia.search_relaxed(query) || @duckduckgo.search_web(query)
  rescue => e
    warn "[Orchestrator] Erreur relaxée : #{e.message}"
    nil
  end

  def search_with_synonyms(query, keywords)
    keywords.each do |word|
      synonyms = @wiktionary.find_synonyms(word)
      next if synonyms.empty?

      synonyms.each do |syn|
        new_query = query.gsub(/#{Regexp.escape(word)}/i, syn)
        result    = search_relaxed(new_query)
        return result if result
      end
    end
    nil
  rescue => e
    warn "[Orchestrator] Erreur synonymes : #{e.message}"
    nil
  end

  def search_with_definitions(query, keywords)
    keywords.sort_by { |w| -w.length }.each do |word|
      definition = @wiktionary.definition(word)
      next if definition.nil?

      definition_keywords = KeywordExtractor.extract(definition).first(2)
      next if definition_keywords.empty?

      other_keywords = keywords.reject { |k| k == word }
      nq = (other_keywords + [definition_keywords.first]).join(" ")
      result = search_relaxed(nq)
      return result if result

      if definition_keywords.size > 1
        nq = (other_keywords + [definition_keywords.last]).join(" ")
        result = search_relaxed(nq)
        return result if result
      end
    end
    nil
  rescue => e
    warn "[Orchestrator] Erreur définitions : #{e.message}"
    nil
  end

  def search_with_spelling_correction(query, keywords)
    corrected_keywords = keywords.map { |w| @wiktionary.correct_spelling(w) || w }
    return nil if corrected_keywords == keywords

    search_direct(corrected_keywords.join(" "))
  rescue => e
    warn "[Orchestrator] Erreur correction : #{e.message}"
    nil
  end
end
