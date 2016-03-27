require 'faraday'
require 'json'
require_relative '../objects/subreddit'
require_relative '../objects/user'
require_relative '../objects/access'

module NeonRAW
  # The underlying base for the client
  class Base
    def api_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => "bearer #{@access.access_token}"
      }
    end

    def api_connection
      @api_connection = Faraday.new(
        'https://oauth.reddit.com',
        headers: api_headers
      )
    end

    def auth_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => Faraday.basic_auth(@client_id, @secret)
      }
    end

    def auth_connection
      @auth_connection = Faraday.new(
        'https://www.reddit.com',
        headers: auth_headers
      )
    end

    def request_data(path, meth, params = {})
      data = api_connection.send :"#{meth}" do |req|
        req.url(path)
        req.params = params
      end
      JSON.parse(data.body, symbolize_names: true)
    end

    def get_subreddit(name)
      data = request_data("/r/#{name}/about.json", 'get')[:data]
      Objects::Subreddit.new(data)
    end

    def get_user(name)
      data = request_data("/user/#{name}/about.json", 'get')[:data]
      Objects::User.new(data)
    end

    def me
      data = request_data('/api/v1/me', 'get')
      Objects::Me.new(data)
    end
  end
end
