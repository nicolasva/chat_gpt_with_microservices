require "digest"

# Decorator : ajoute du cache Redis autour de n'importe quel service de recherche.
# Le service wrappé doit répondre à #search(query).
#
# Usage :
#   wikipedia = WikipediaService.new(intent_detector: detector)
#   cached_wikipedia = CachedSearch.new(wikipedia, ttl: 2.hours)
#   cached_wikipedia.search("quel est le capital de la France ?")
class CachedSearch
  def initialize(service, cache: Rails.cache, ttl: 1.hour)
    @service = service
    @cache   = cache
    @ttl     = ttl
  end

  def search(query)
    cache_key = "search:#{Digest::MD5.hexdigest(query)}"
    @cache.fetch(cache_key, expires_in: @ttl) { @service.search(query) }
  end
end
