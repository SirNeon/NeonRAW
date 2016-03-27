require 'faraday'
require 'json'
require_relative '../objects/subreddit'
require_relative '../objects/user'
require_relative '../objects/me'
require_relative '../objects/access'

module NeonRAW
  # The underlying base for the client
  class Base
    # Creates headers for oAuth2 requests.
    # @!method api_headers
    # @return [Hash] Returns oAuth2 headers.
    def api_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => "bearer #{@access.access_token}"
      }
    end

    # Creates the connection for oAuth2 requests.
    # @!method api_connection
    # @return [Faraday::Connection] Returns the connection.
    def api_connection
      @api_connection ||= Faraday.new(
        'https://oauth.reddit.com',
        headers: api_headers
      )
    end

    # Creates the headers used to authenticate your account
    # via oAuth2.
    # @!method auth_headers
    # @return [Hash] Returns the headers.
    def auth_headers
      {
        'User-Agent' => @user_agent,
        'Authorization' => Faraday.basic_auth(@client_id, @secret)
      }
    end

    # Creates the connection used to authorize the client.
    # @!method auth_connection
    # @return [Faraday::Connection] Returns the connection.
    def auth_connection
      @auth_connection ||= Faraday.new(
        'https://www.reddit.com',
        headers: auth_headers
      )
    end

    # Requests data from Reddit.
    # @!method request_data
    # @param path [String] The API path to connect to.
    # @param meth [String] The request method to use.
    # @param params [Hash] Parameters for the request.
    # @return [Hash] Returns the parsed JSON as a hash containing
    #   the data.
    def request_data(path, meth, params = {})
      refresh_access! if @access.expired?
      data = api_connection.send :"#{meth}" do |req|
        req.url(path)
        req.params = params
      end
      sleep(1) # API rate limit
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
