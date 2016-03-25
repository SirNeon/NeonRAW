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
      @user_agent = opts[:user_agent] || "NeonRAW v#{NeonRAW::VERSION}"
    end

    def authorize!
      auth_connection.post(
        '/api/v1/access_token',
        grant_type: 'password',
        username: @username,
        password: @password
      )
    end
  end
end
