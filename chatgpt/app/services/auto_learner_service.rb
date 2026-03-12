# Gère l'apprentissage automatique.
# Le stockage dataset est délégué à dataset-service via DatasetServiceClient.
class AutoLearnerService
  def initialize(compound_resolver:)
    @compound_resolver = compound_resolver
    @pending           = {}
  end

  def learn_pending(session_id, answer)
    pending = @pending.delete(session_id)
    return if pending.nil? || pending.empty?

    pending.each do |msg|
      next if TextNormalizerService.normalize(msg).empty?
      DatasetServiceClient.post("/dataset", { "question" => msg.downcase.strip, "answer" => answer })
    end
  end

  def handle_fallback(session_id, msg, answer)
    msg = UserMessage.new(raw: msg.to_s, session_id: session_id) unless msg.is_a?(UserMessage)

    if web_answer?(answer)
      save_web_answer_if_relevant(session_id, msg, answer)
    elsif !answer&.start_with?("Météo à")
      add_pending(session_id, msg.raw)
    end
  end

  private

  def save_web_answer_if_relevant(session_id, msg, answer)
    normalized_q      = msg.raw.downcase.strip
    question_keywords = KeywordExtractorService.extract(@compound_resolver.resolve(msg.raw))
    relevant          = question_keywords.any? { |kw| answer.downcase.include?(kw) }

    if relevant
      DatasetServiceClient.post("/dataset", { "question" => normalized_q, "answer" => answer })
      Rails.logger.info "[AutoLearnerService] Appris depuis le web : '#{normalized_q}'"
    else
      Rails.logger.info "[AutoLearnerService] Réponse web non pertinente, mise en attente : '#{normalized_q}'"
      add_pending(session_id, msg.raw)
    end
  end

  def add_pending(session_id, message)
    @pending[session_id] ||= []
    @pending[session_id] << message
  end

  def web_answer?(answer)
    return false if answer.nil?
    SearchResult::WEB_SOURCES.any? { |src| answer.include?(src) && answer.length > src.length + 20 }
  end
end
