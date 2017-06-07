require 'cgi'
require_relative 'base'

module NeonRAW
  module Clients
    # The installed app client.
    class Installed < Base
      def initialize(client_id, redirect_uri, opts = {})
        @client_id = client_id
        @redirect_uri = redirect_uri
        @requests_remaining = 1
        @ratelimit_reset = 0
        @user_agent = opts[:user_agent] ||
                      "Powered by NeonRAW v#{NeonRAW::VERSION}"
      end

      # Generates the authorization URL.
      # @!method auth_url(state, scope = ['identity'], duration = 'temporary')
      # @param state [String] A random string to check later.
      # @param scope [Array<String>] The scope the app uses.
      # @return [String] Returns the URL.
      def auth_url(state, scope = ['identity'], duration = 'temporary')
        query = {
          response_type: 'token',
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
      # @!method authorize!(fragment)
      # @param fragment [String] The part of the URL after the #.
      def authorize!(fragment)
        data = CGI.parse(fragment)
        access_data = {
          access_token: data[:access_token].first,
          token_type: data[:token_type].first,
          expires_in: data[:expires_in].first,
          scope: data[:scope].first
        }
        @access = Objects::Access.new(access_data)
      end
    end
  end
end
