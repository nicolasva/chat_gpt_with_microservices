# Decorator : ajoute du logging autour de n'importe quel service de recherche.
# Le service wrappé doit répondre à #search(query).
#
# Usage :
#   wikipedia = WikipediaService.new(intent_detector: detector)
#   logged_wikipedia = LoggedSearch.new(wikipedia, label: "Wikipedia")
#   logged_wikipedia.search("qui a peint la Joconde ?")
class LoggedSearch
  def initialize(service, label:)
    @service = service
    @label   = label
  end

  def search(query)
    Rails.logger.info "[#{@label}] Recherche : #{query}"
    result = @service.search(query)
    Rails.logger.info "[#{@label}] #{result ? 'Résultat trouvé' : 'Aucun résultat'}"
    result
  end
end
