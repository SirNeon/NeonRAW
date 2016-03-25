require 'faraday'

module NeonRAW
  # The underlying base connection for the client
  class Base
    def connection
      Faraday.new(url: 'https://www.reddit.com') do |faraday|
        faraday.adapter :typhoeus
      end
    end

    def auth_connection
      Faraday.new(url: 'https://oauth.reddit.com') do |faraday|
        faraday.adapter :typhoeus
      end
    end
  end
end
