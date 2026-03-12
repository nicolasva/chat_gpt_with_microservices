require "couchrest"

module CouchClient
  COUCH_URL = ENV.fetch("COUCHDB_URL", "http://admin:admin@127.0.0.1:5984")

  def self.db(name)
    CouchRest.database!("#{COUCH_URL}/#{name}")
  end
end
