# Proxy vers dataset-service pour la recherche exacte + similarité Jaccard.
class DatasetQuery
  def find_best_match(user_message)
    result = DatasetServiceClient.post("/dataset/match", { question: user_message })
    result&.dig("doc")
  end
end
