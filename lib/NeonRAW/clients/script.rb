require_relative 'base'

module NeonRAW
  module Clients
    # The script app client.
    class Script < Base
      def initialize(creds)
        @username = creds[:username]
        @password = creds[:password]
        @client_id = creds[:client_id]
        @secret = creds[:secret]
        @redirect_uri = creds[:redirect_uri] || 'http://127.0.0.1:'
        @requests_remaining = 1
        @ratelimit_reset = 0
        @user_agent = creds[:user_agent] ||
                      "Powered by NeonRAW v#{NeonRAW::VERSION}"
        authorize!
      end

      # Authorizes the client for oAuth2 requests.
      # @!method authorize!
      # @!method refresh_access!
      def authorize!
        response = auth_connection(
          '/api/v1/access_token', :post,
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
end
