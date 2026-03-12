# encoding: utf-8

Given("le chatbot est initialisé") do
  @service = ChatGptService.new
  @session_id = "cucumber-#{SecureRandom.hex(4)}"
end

When("je dis {string}") do |message|
  @response = @service.predict(message, @session_id)
end

Then("la réponse devrait être {string}") do |expected|
  expect(@response).to eq(expected)
end

Then("la réponse devrait être parmi:") do |table|
  possible_answers = table.raw.flatten
  expect(possible_answers).to include(@response),
    "Attendu une de #{possible_answers.inspect}, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait contenir {string}") do |substring|
  expect(@response).to include(substring),
    "Attendu que la réponse contienne #{substring.inspect}, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait contenir un de:") do |table|
  substrings = table.raw.flatten
  matched = substrings.any? { |s| @response.downcase.include?(s.downcase) }
  expect(matched).to be(true),
    "Attendu que la réponse contienne un de #{substrings.inspect}, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait commencer par {string}") do |prefix|
  expect(@response).to start_with(prefix),
    "Attendu que la réponse commence par #{prefix.inspect}, mais reçu : #{@response.inspect}"
end

Then("la réponse ne devrait pas être vide") do
  expect(@response).not_to be_nil
  expect(@response).not_to be_empty
end

Then("la réponse devrait être une réponse positive") do
  expect(FallbackResponderService::POSITIVE_RESPONSES).to include(@response),
    "Attendu une réponse positive, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait être une réponse négative") do
  expect(FallbackResponderService::NEGATIVE_RESPONSES).to include(@response),
    "Attendu une réponse négative, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait être une réponse de question") do
  expect(FallbackResponderService::QUESTION_RESPONSES).to include(@response),
    "Attendu une réponse de question, mais reçu : #{@response.inspect}"
end

Then("la réponse devrait être une réponse par défaut") do
  expect(FallbackResponderService::DEFAULT_RESPONSES).to include(@response),
    "Attendu une réponse par défaut, mais reçu : #{@response.inspect}"
end
