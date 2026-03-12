require "net/http"
require "uri"
require "json"
require_relative "text_normalizer"
require_relative "keyword_extractor"
require_relative "similarity_calculator"
require_relative "nlp_client"
require_relative "local_intent_detector"

class Wikipedia
  def search(query)
    keywords    = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    query_words = TextNormalizer.normalize(query)
    indicators  = LocalIntentDetector.country_indicators.any? ? LocalIntentDetector.country_indicators : %w[pays état nation puissance puissant]

    if query_words.any? { |qw| indicators.any? { |w| SimilarityCalculator.stem_match?(qw, w) } }
      result = search_country_related(query, query_words, keywords, indicators)
      return result if result
    end

    if query.match?(/\b(le|la|les)\s+(plus|moins)\b/i)
      list_keywords = ["liste"] + keywords
      extract = wiki_search("fr", list_keywords, query)
      if extract && relevant?(extract, query)
        return format_result(extract)
      end
    end

    cast_words = LocalIntentDetector.cast_words
    if cast_words.any? { |w| query_words.any? { |qw| SimilarityCalculator.stem_match?(qw, w) } }
      film_keywords = keywords + ["film"]
      extract = wiki_search("fr", film_keywords, query)
      return format_result(extract) if extract
    end

    extract = wiki_search("fr", keywords, query)
    return nil if extract.nil?
    return nil unless relevant?(extract, query)

    format_result(extract)
  rescue => e
    warn "[Wikipedia] Erreur search : #{e.message}"
    nil
  end

  def search_relaxed(query)
    keywords = KeywordExtractor.extract(query)
    return nil if keywords.empty?

    extract = wiki_query("fr", keywords.join(" "), query, relaxed: true)
    extract ? format_result(extract) : nil
  rescue => e
    warn "[Wikipedia] Erreur relaxé : #{e.message}"
    nil
  end

  def relevant?(extract, query)
    return true if query.nil? || query.empty?

    query_kw = KeywordExtractor.extract(query)
    return true if query_kw.empty? || query_kw.size <= 1

    intro      = extract.split(/[.\n]/).first.to_s
    intro_norm = TextNormalizer.strip_accents(intro.downcase)
    matched    = query_kw.count { |kw| intro_norm.include?(TextNormalizer.strip_accents(kw)) }
    min_needed = [(query_kw.size * 2 / 3.0).ceil, 1].max
    matched >= min_needed
  end

  def wiki_search_individual(lang, keywords, original_query = "")
    keywords.sort_by { |w| -w.length }.each do |keyword|
      result = wiki_query(lang, keyword, original_query)
      return result if result
    end
    nil
  rescue => e
    warn "[Wikipedia] Erreur individuel #{lang} : #{e.message}"
    nil
  end

  def wiki_query(lang, search_text, original_query = "", relaxed: false)
    search_term = URI.encode_www_form_component(search_text)
    uri         = URI("https://#{lang}.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{search_term}&srlimit=5&format=json")
    response    = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    data    = JSON.parse(response.body)
    results = data.dig("query", "search")

    if results.nil? || results.empty?
      suggestion = data.dig("query", "searchinfo", "suggestion")
      return wiki_query(lang, suggestion, original_query, relaxed: relaxed) if suggestion
      return nil
    end

    search_words     = TextNormalizer.normalize(search_text)
    min_required     = [(search_words.size / 2.0).ceil, 1].max
    matching_results = []

    results.each_with_index do |r, idx|
      title_words   = TextNormalizer.normalize(r["title"])
      snippet_text  = r["snippet"].to_s.gsub(/<[^>]*>/, "").gsub(/&#0*39;/, "'").gsub(/&amp;/, "&").gsub(/&quot;/, '"').downcase
      snippet_words = TextNormalizer.normalize(snippet_text)

      title_match    = SimilarityCalculator.stem_match_count(search_words, title_words)
      unmatched      = search_words.reject { |sw| title_words.any? { |tw| SimilarityCalculator.stem_match?(sw, tw) } }
      snippet_bonus  = SimilarityCalculator.stem_match_count(unmatched, snippet_words)
      unique_matches = title_match + snippet_bonus
      weighted_score = title_match * 2 + snippet_bonus

      matching_results << { result: r, title_match: title_match, snippet_bonus: snippet_bonus, unique_matches: unique_matches, weighted_score: weighted_score, index: idx } if unique_matches >= min_required
    end

    matching_results.sort_by! { |m| [-m[:weighted_score], -m[:title_match], m[:index]] }

    matching_results.each do |m|
      page_title = m[:result]["title"]
      extract    = wiki_extract(lang, page_title, original_query)
      return extract if extract
    end

    if relaxed
      results.each do |r|
        next if matching_results.any? { |m| m[:result]["title"] == r["title"] }
        title_words = TextNormalizer.normalize(r["title"])
        snippet     = r["snippet"].to_s.gsub(/<[^>]*>/, "").downcase
        found_words = search_words.select { |w| title_words.include?(w) || snippet.include?(w) }
        if found_words.size >= min_required
          extract = wiki_extract(lang, r["title"], original_query)
          return extract if extract
        end
      end
    end

    nil
  rescue => e
    warn "[Wikipedia] Erreur wiki_query : #{e.message}"
    nil
  end

  def wiki_extract(lang, page_title, original_query = "")
    encoded_title = URI.encode_www_form_component(page_title)
    uri           = URI("https://#{lang}.wikipedia.org/w/api.php?action=query&titles=#{encoded_title}&prop=extracts&explaintext=1&redirects=1&format=json")
    response      = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    pages     = JSON.parse(response.body).dig("query", "pages")
    full_text = pages&.values&.first&.dig("extract")
    return nil if full_text.nil? || full_text.strip.empty?

    if disambiguation_page?(full_text)
      return follow_disambiguation(lang, page_title, original_query, full_text)
    end

    clean_text = full_text.gsub(/Sauf indication contraire[^.]*\./, "")
                          .gsub(/==\s*Voir aussi\s*==.*\z/m, "")
                          .gsub(/==\s*Notes et références\s*==.*\z/m, "")
                          .strip

    if clean_text.length < 300
      table_text = wiki_extract_table(lang, page_title)
      if table_text
        intro_line = clean_text.split("\n").first.to_s.strip
        return "#{intro_line}\n#{table_text}" unless table_text.empty?
      end
    end

    best_section = NlpClient.find_best_section(clean_text, original_query)

    if best_section.length > 2000
      best_section = best_section[0..1999]
      last_newline = best_section.rindex("\n")
      best_section = best_section[0..last_newline - 1] if last_newline && last_newline > 100
    end

    best_section.strip.empty? ? nil : best_section
  rescue => e
    warn "[Wikipedia] Erreur wiki_extract '#{page_title}' : #{e.message}"
    nil
  end

  def wiki_extract_table(lang, page_title)
    encoded  = URI.encode_www_form_component(page_title)
    uri      = URI("https://#{lang}.wikipedia.org/w/api.php?action=parse&page=#{encoded}&prop=text&redirects=1&format=json")
    response = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    html = JSON.parse(response.body).dig("parse", "text", "*")
    return nil if html.nil?

    rows = []
    html.scan(/<tr[^>]*>(.*?)<\/tr>/m).each do |tr|
      cells = tr[0].scan(/<t[dh][^>]*>(.*?)<\/t[dh]>/m).map do |c|
        c[0].gsub(/<[^>]*>/, "")
            .gsub(/&nbsp;|&#160;/, " ").gsub(/&gt;/, ">").gsub(/&lt;/, "<")
            .gsub(/&amp;/, "&").gsub(/&#91;.*?&#93;/, "").gsub(/\[.*?\]/, "").strip
      end
      row = cells.reject(&:empty?)
      rows << row if row.size >= 2
    end

    return nil if rows.empty?
    data_rows = rows[1..]
    return nil if data_rows.nil? || data_rows.empty?

    data_rows.first(15).map { |row| row.join(" — ") }.join("\n")
  rescue => e
    warn "[Wikipedia] Erreur tableau '#{page_title}' : #{e.message}"
    nil
  end

  def follow_disambiguation(lang, page_title, original_query, disambig_text)
    encoded  = URI.encode_www_form_component(page_title)
    uri      = URI("https://#{lang}.wikipedia.org/w/api.php?action=query&titles=#{encoded}&prop=links&pllimit=30&plnamespace=0&format=json")
    response = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    pages = JSON.parse(response.body).dig("query", "pages")
    return nil if pages.nil?

    links       = pages.values.first&.dig("links") || []
    link_titles = links.map { |l| l["title"] }.compact
    return nil if link_titles.empty?

    disambig_lines = disambig_text.split("\n").map(&:strip).reject(&:empty?)
    query_keywords = KeywordExtractor.extract(original_query)
    page_words     = TextNormalizer.normalize(page_title)
    discriminating = query_keywords.reject { |qw| page_words.any? { |pw| SimilarityCalculator.stem_match?(qw, pw) } }
    discriminating = query_keywords if discriminating.empty?

    scored = link_titles.map do |title|
      title_lower    = title.downcase
      title_words    = TextNormalizer.normalize(title)
      matching_lines = disambig_lines.select { |line| line.downcase.include?(title_lower) || title_words.all? { |tw| line.downcase.include?(tw) } }
      desc_words     = matching_lines.flat_map { |line| TextNormalizer.normalize(line) }.uniq

      desc_match   = discriminating.count { |qw| desc_words.any? { |dw| SimilarityCalculator.stem_match?(qw, dw) } }
      title_match  = discriminating.count { |qw| title_words.any? { |tw| SimilarityCalculator.stem_match?(qw, tw) } }
      year_penalty = title.match?(/\b(19|20)\d{2}\b/) ? 2 : 0
      list_penalty = title.downcase.start_with?("liste") ? 2 : 0
      score        = desc_match * 3 + title_match * 2 - year_penalty - list_penalty

      { title: title, score: score }
    end

    scored.sort_by! { |s| -s[:score] }
    scored.select! { |s| s[:score] > 0 }

    scored.first(3).each do |s|
      extract = wiki_extract(lang, s[:title], original_query)
      return extract if extract
    end
    nil
  rescue => e
    warn "[Wikipedia] Erreur follow_disambiguation : #{e.message}"
    nil
  end

  private

  def search_country_related(query, query_words, keywords, indicators)
    has_power_word = query_words.any? { |qw| %w[puissant puissants puissantes puissance puissances].any? { |w| SimilarityCalculator.stem_match?(qw, w) } }
    if has_power_word
      extract = wiki_search("fr", ["grande", "puissance", "pays"], query)
      return format_result(extract) if extract
    end

    topic_only = keywords.reject { |k| indicators.any? { |w| SimilarityCalculator.stem_match?(k, w) } }
    if topic_only.any? && topic_only != keywords
      core_topic = topic_only.reject { |w| w.match?(/\A[a-zà-ÿ]+(ent|ons|ez|aient|ront|raient)\z/) }
      core_topic = topic_only if core_topic.empty?
      extract = wiki_search("fr", core_topic, query)
      return format_result(extract) if extract

      if core_topic != topic_only
        extract = wiki_search("fr", topic_only, query)
        return format_result(extract) if extract
      end
    end

    extract = wiki_search("fr", ["liste"] + keywords, query)
    format_result(extract) if extract
  end

  def wiki_search(lang, keywords, original_query = "")
    wiki_query(lang, keywords.join(" "), original_query)
  rescue => e
    warn "[Wikipedia] Erreur wiki_search #{lang} : #{e.message}"
    nil
  end

  def disambiguation_page?(text)
    text.include?("peut faire référence") || text.include?("peut désigner") ||
      text.include?("Cette page d'homonymie") || text.include?("page d'homonymie") ||
      text.match?(/\A[^\n]{0,50}\s+peut\s+(faire référence|désigner|se référer)/)
  end

  def format_result(extract)
    "D'après Wikipedia : #{extract}"
  end
end
