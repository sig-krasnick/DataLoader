# frozen_string_literal: true

require 'json'
require 'net/http'

class DataLoader
  URL = 'https://s3.amazonaws.com/coderbyteprojectattachments/serasystems-tkzr9-a1tb5deh-items-formatted.json'

  def self.load_data
    uri = URI(URL)
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)[:data]
  end
end
