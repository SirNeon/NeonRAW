require 'cgi'
require_relative 'base'

module NeonRAW
  module Clients
    # The installed app client.
    class Installed < Base
      def initialize(client_id, redirect_uri, opts = {})
        @client_id = client_id
        @redirect_uri = redirect_uri
        @user_agent = opts[:user_agent] ||
                      "Powered by NeonRAW v#{NeonRAW::VERSION}"
      end

      # Generates the authorization URL.
      # @!method auth_url(state, scope = ['*'], duration = 'temporary')
      # @param state [String] A random string to check later.
      # @param scope [Array<String>] The scope the app uses.
      # @param duration [String] The duration of the access token [temporary,
      #   permanent].
      # @return [String] Returns the URL.
      def auth_url(state, scope = ['*'], duration = 'temporary')
        query = {
          response_type: 'token',
          client_id: @client_id,
          redirect_uri: @redirect_uri,
          state: state,
          scope: scope.join(',').chop,
          duration: duration
        }
        url = URI.join('https://www.reddit.com', '/api/v1/authorize')
        url.query = URI.encode_www_form(query)
        url.to_s
      end

      def authorize!(fragment)
        data = CGI.parse(fragment)
        p data
      end
    end
  end
end
