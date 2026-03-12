require "faraday"
require "json"

# Client HTTP partagé vers dataset-service.
module DatasetServiceClient
  DATASET_SERVICE_URL = ENV.fetch("DATASET_SERVICE_URL", "http://localhost:3004")

  def self.connection
    @connection ||= Faraday.new(url: DATASET_SERVICE_URL) do |f|
      f.options.open_timeout = 2
      f.options.timeout      = 10
      f.request  :json
      f.response :json
    end
  end

  def self.post(path, payload)
    response = connection.post(path, payload)
    return nil unless response.success?

    response.body
  rescue => e
    Rails.logger.error "[DatasetServiceClient] POST #{path} : #{e.message}"
    nil
  end

  def self.get(path)
    response = connection.get(path)
    return nil unless response.success?

    response.body
  rescue => e
    Rails.logger.error "[DatasetServiceClient] GET #{path} : #{e.message}"
    nil
  end

  def self.delete(path, payload)
    response = connection.delete(path) do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json
    end
    response.success?
  rescue => e
    Rails.logger.error "[DatasetServiceClient] DELETE #{path} : #{e.message}"
    false
  end
end
