require 'uri'
require_relative 'base'

module NeonRAW
  module Clients
    # The Web app client.
    class Web < Base
      def initialize(client_id, secret, redirect_uri, opts = {})
        @client_id = client_id
        @secret = secret
        @redirect_uri = redirect_uri
        @requests_remaining = 1
        @ratelimit_reset = 0
        @user_agent = opts[:user_agent] ||
                      "Powered by NeonRAW v#{NeonRAW::VERSION}"
      end

      # Generates the authorization URL.
      # @!method auth_url(state, scope = ['identity'], duration = 'temporary')
      # @param state [String] A random string to check later.
      # @param scope [Array<String>] The scopes your app uses.
      # @param duration [String] The duration of the access token [temporary,
      #   permanent].
      # @return [String] Returns the URL.
      def auth_url(state, scope = ['identity'], duration = 'temporary')
        query = {
          response_type: 'code',
          client_id: @client_id,
          redirect_uri: @redirect_uri,
          state: state,
          scope: scope.join(','),
          duration: duration
        }
        url = URI.join('https://www.reddit.com', '/api/v1/authorize')
        url.query = URI.encode_www_form(query)
        url.to_s
      end

      # Authorizes the client.
      # @!method authorize!(code)
      # @param code [String] The authorization code.
      def authorize!(code)
        response = auth_connection(
          '/api/v1/access_token', :post,
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: @redirect_uri
        )
        data = JSON.parse(response.body, symbolize_names: true)
        @access = Objects::Access.new(data)
      end
    end
  end
end
