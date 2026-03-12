require "json"
require "set"
require_relative "couch_client"
require_relative "text_normalizer"
require_relative "similarity_calculator"
require_relative "keyword_extractor"

class DatasetStore
  DB_NAME      = "chatgpt_dataset"
  DATASET_PATH = File.join(__dir__, "..", "dataset.json")
  WEB_PREFIXES = ["D'après Wikipedia", "D'après DuckDuckGo", "Résultats DuckDuckGo", "Résultats Tavily"].freeze
  SIMILARITY_THRESHOLD = 0.5

  def initialize
    @db = CouchClient.db(DB_NAME)
  end

  # ── CRUD ─────────────────────────────────────────────────────────────────

  def all
    @db.all_docs(include_docs: true)["rows"].map { |r| r["doc"] }.compact
  end

  def create(attrs)
    doc = @db.save_doc(attrs)
    attrs.merge("_id" => doc["id"], "_rev" => doc["rev"])
  end

  def delete(id, rev)
    @db.delete_doc({ "_id" => id, "_rev" => rev })
  rescue => e
    warn "[DatasetStore] Erreur suppression : #{e.message}"
    false
  end

  def exists?(question)
    normalized = TextNormalizer.normalize(question)
    all.any? { |d| d["question"] && TextNormalizer.normalize(d["question"]) == normalized }
  end

  # ── SEARCH ────────────────────────────────────────────────────────────────

  def find_best_match(question)
    docs = all
    find_exact_match(question, docs) || find_similarity_match(question, docs)
  end

  # ── SEED + CLEANUP ────────────────────────────────────────────────────────

  def seed_if_empty!
    docs = all
    if docs.empty? && File.exist?(DATASET_PATH)
      json_data = JSON.parse(File.read(DATASET_PATH))
      json_data.each { |d| @db.save_doc(d) }
      warn "[DatasetStore] #{json_data.size} entrées importées depuis dataset.json"
    end
  end

  def cleanup_web_entries!
    original_questions = load_original_questions
    docs               = all
    removed            = 0

    docs.each do |doc|
      next unless doc["answer"] && doc["question"]
      next if original_questions.include?(doc["question"]&.downcase&.strip)
      next unless WEB_PREFIXES.any? { |p| doc["answer"].start_with?(p) }

      delete(doc["_id"], doc["_rev"])
      removed += 1
    end

    warn "[DatasetStore] #{removed} entrée(s) web supprimée(s)" if removed > 0
  end

  private

  def find_exact_match(question, docs)
    user_words = TextNormalizer.normalize(question)
    exact = docs.select { |d| d["question"] && TextNormalizer.normalize(d["question"]) == user_words }
    exact.sample
  end

  def find_similarity_match(question, docs)
    user_words_filtered = SimilarityCalculator.normalize_for_matching(question)
    best_doc   = nil
    best_score = 0.0

    docs.each do |d|
      next unless d["question"]
      score = SimilarityCalculator.jaccard(user_words_filtered, SimilarityCalculator.normalize_for_matching(d["question"]))
      if score > best_score
        best_score = score
        best_doc   = d
      end
    end

    best_score > SIMILARITY_THRESHOLD ? best_doc : nil
  end

  def load_original_questions
    questions = Set.new
    if File.exist?(DATASET_PATH)
      JSON.parse(File.read(DATASET_PATH)).each do |d|
        questions << d["question"]&.downcase&.strip if d["question"]
      end
    end
    questions
  end
end
