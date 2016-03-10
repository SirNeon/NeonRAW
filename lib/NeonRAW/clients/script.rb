require 'faraday'
require 'multi_json'

module NeonRAW
  class script
    headers = { 'User-Agent' => "Powered by NeonRAW v#{NeonRAW::VERSION}",
                'Authorization' => Faraday.basic_auth(@client_id, @secret) }
    conn = Faraday.new(url: 'https://www.reddit.com',
                       headers: headers) do |faraday|
      faraday.adapter :typhoeus
    end
  end
end
