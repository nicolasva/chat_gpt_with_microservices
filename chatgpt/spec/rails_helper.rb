require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Charger automatiquement les fichiers support
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

RSpec.configure do |config|
  config.use_active_record = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Exclure les tests lents (API externes) sauf si RUN_SLOW_TESTS=1
  config.filter_run_excluding :slow unless ENV["RUN_SLOW_TESTS"]
end
