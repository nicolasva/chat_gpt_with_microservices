namespace :couchdb do
  desc "Configure les bases CouchDB et les vues (équivalent db:migrate)"
  task setup: :environment do
    puts "=== Configuration CouchDB ==="

    # Créer les bases de données (database! crée si inexistant)
    puts "Création de la base chatgpt_dataset..."
    Dataset.db
    puts "  -> OK"

    puts "Création de la base chatgpt_memory..."
    Memory.db
    puts "  -> OK"

    # Créer les vues CouchDB
    puts "Création des vues CouchDB..."
    Memory.ensure_views!
    puts "  -> OK"

    puts "=== Configuration terminée ==="
  end

  desc "Importe le dataset.json dans CouchDB (équivalent db:seed)"
  task seed: :environment do
    puts "=== Import du dataset ==="
    docs = Dataset.seed_if_empty!
    puts "#{docs.size} entrées dans le dataset"
    puts "=== Import terminé ==="
  end

  desc "Setup + seed (équivalent db:setup)"
  task init: [:setup, :seed]

  desc "Supprime et recrée les bases CouchDB (équivalent db:reset)"
  task reset: :environment do
    puts "=== Reset CouchDB ==="
    couch_url = ENV.fetch("COUCHDB_URL", "http://admin:admin@127.0.0.1:5984")

    %w[chatgpt_dataset chatgpt_memory].each do |db_name|
      uri = URI("#{couch_url}/#{db_name}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Delete.new(uri)
      response = http.request(request)
      puts "Suppression #{db_name} : #{response.code}"
    end

    # Recréer
    Rake::Task["couchdb:setup"].invoke
    Rake::Task["couchdb:seed"].invoke
    puts "=== Reset terminé ==="
  end
end
