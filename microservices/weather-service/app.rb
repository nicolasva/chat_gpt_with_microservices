require "sinatra"
require "sinatra/json"
require "net/http"
require "uri"
require "json"

WEATHER_WORDS     = %w[temps météo meteo température temperature climat pluie soleil neige vent chaud froid].freeze
QUESTION_WORDS    = %w[qui que quoi quel quelle quels quelles où comment pourquoi quand combien est-ce].freeze
CITY_PREPOSITIONS = %w[à a au en sur].freeze

set :port, 3001
set :bind, "0.0.0.0"
disable :protection

# GET /weather?city=Paris
get "/weather" do
  city = params[:city]&.strip
  city = "Paris" if city.nil? || city.empty?

  encoded_city = URI.encode_www_form_component(city)
  uri          = URI("https://wttr.in/#{encoded_city}?format=j1&lang=fr")
  response     = Net::HTTP.get_response(uri)

  halt 502, json(error: "wttr.in indisponible") unless response.code == "200"

  current = JSON.parse(response.body)["current_condition"]&.first
  halt 404, json(error: "Données météo introuvables") unless current

  temp        = current["temp_C"]
  feels_like  = current["FeelsLikeC"]
  humidity    = current["humidity"]
  description = current.dig("lang_fr", 0, "value") || current.dig("weatherDesc", 0, "value")

  json(
    city:        city.capitalize,
    temperature: temp.to_i,
    feels_like:  feels_like.to_i,
    humidity:    humidity.to_i,
    description: description,
    summary:     "Météo à #{city.capitalize} : #{description}, #{temp}°C (ressenti #{feels_like}°C), humidité #{humidity}%."
  )
rescue => e
  halt 500, json(error: e.message)
end

# POST /extract_city  body: { message: "quel temps fait-il à Lyon ?" }
post "/extract_city" do
  request.body.rewind
  body    = JSON.parse(request.body.read)
  message = body["message"].to_s

  words = message.downcase.gsub(/[?!.,]/, "").split
  city  = nil

  words.each_with_index do |w, i|
    next unless CITY_PREPOSITIONS.include?(w) && words[i + 1]

    city_parts = []
    (i + 1...words.size).each do |j|
      break if WEATHER_WORDS.include?(words[j]) || QUESTION_WORDS.include?(words[j]) || %w[aujourd'hui demain ce cette].include?(words[j])
      city_parts << words[j]
    end

    if city_parts.any?
      city = city_parts.join(" ")
      break
    end
  end

  json(city: city)
rescue => e
  halt 400, json(error: e.message)
end

get "/health" do
  json(status: "ok")
end
