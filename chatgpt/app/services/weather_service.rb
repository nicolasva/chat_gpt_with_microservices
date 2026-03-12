require "net/http"
require "uri"
require "json"

class WeatherService
  WEATHER_WORDS     = %w[temps météo meteo température temperature climat pluie soleil neige vent chaud froid].freeze
  QUESTION_WORDS    = %w[qui que quoi quel quelle quels quelles où comment pourquoi quand combien est-ce].freeze
  CITY_PREPOSITIONS = %w[à a au en sur].freeze

  WEATHER_SERVICE_URL = ENV.fetch("WEATHER_SERVICE_URL", "http://localhost:3001")

  def search(message)
    city = extract_city(message) || "Paris"

    uri      = URI("#{WEATHER_SERVICE_URL}/weather?city=#{URI.encode_www_form_component(city)}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.code == "200"

    JSON.parse(response.body)["summary"]
  rescue => e
    Rails.logger.error "[WeatherService] Erreur appel microservice : #{e.message}"
    nil
  end

  def extract_city(message)
    uri      = URI("#{WEATHER_SERVICE_URL}/extract_city")
    http     = Net::HTTP.new(uri.host, uri.port)
    request  = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { message: message }.to_json
    response = http.request(request)
    return nil unless response.code == "200"

    JSON.parse(response.body)["city"]
  rescue => e
    Rails.logger.error "[WeatherService] Erreur extract_city : #{e.message}"
    fallback_extract_city(message)
  end

  private

  def fallback_extract_city(message)
    words = message.downcase.gsub(/[?!.,]/, "").split
    words.each_with_index do |w, i|
      next unless CITY_PREPOSITIONS.include?(w) && words[i + 1]

      city_parts = []
      (i + 1...words.size).each do |j|
        break if WEATHER_WORDS.include?(words[j]) || QUESTION_WORDS.include?(words[j]) || %w[aujourd'hui demain ce cette].include?(words[j])
        city_parts << words[j]
      end
      return city_parts.join(" ") if city_parts.any?
    end
    nil
  end
end
