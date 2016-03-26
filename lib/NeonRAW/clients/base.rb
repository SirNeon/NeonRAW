require 'faraday'
require 'json'
require_relative '../objects/subreddit'

module NeonRAW
  # The underlying base for the client
  class Base
    def connection
      @connection ||= Faraday.new(url: 'https://www.reddit.com')
    end

    def auth_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => Faraday.basic_auth(@client_id, @secret)
      }
    end

    def auth_connection
      @auth_connection ||= Faraday.new(
        url: 'https://oauth.reddit.com',
        headers: auth_headers
      )
    end

    def request_data(path, params = {})
      data = connection.get do |req|
        req.url(path)
        req.params = params
      end
      JSON.parse(data.body, symbolize_names: true)
    end

    def get_subreddit(name)
      data = request_data("/r/#{name}/about.json")[:data]
      Objects::Subreddit.new(data)
    end
  end
end
