require 'securerandom'
require_relative 'base'

module NeonRAW
  # le script
  class Script < Base
    def initialize(username, password, client_id, secret, opts = {})
      @username = username
      @password = password
      @client_id = client_id
      @secret = secret
      @redirect_uri = opts[:redirect_uri] || 'http://127.0.0.1:'
      @user_agent = opts[:user_agent] ||
                    "Powered by NeonRAW v#{NeonRAW::VERSION}"
      authorize!
    end

    # Authorizes the client for oAuth2 requests.
    # @!method authorize!
    # @!method refresh_access!
    def authorize!
      # When the access gets refreshed the api_connection needs to
      # also be reset so it can use the new api_headers.
      @api_connection = nil
      response = auth_connection.post(
        '/api/v1/access_token',
        grant_type: 'password',
        username: @username,
        password: @password
      )
      data = JSON.parse(response.body, symbolize_names: true)
      @access = Objects::Access.new(data)
    end
    alias refresh_access! authorize!
  end
end
