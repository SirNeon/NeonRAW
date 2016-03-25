require 'faraday'

module NeonRAW
  # The underlying base connection for the client
  class Base
    def connection
      Faraday.new(url: 'https://www.reddit.com')
    end

    def auth_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => Faraday.basic_auth(@client_id, @secret)
      }
    end

    def auth_connection
      Faraday.new(url: 'https://oauth.reddit.com',
                  headers: auth_headers)
    end
  end
end
