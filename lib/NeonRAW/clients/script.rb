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

    # rubocop:disable Metrics/MethodLength
    def authorize!
      connection.get do |req|
        req.url = '/api/v1/authorize'
        req.params['client_id'] = @client_id
        req.params['secret'] = @secret
        req.params['redirect_uri'] = @redirect_uri
        req.params['response_type'] = 'code'
        req.params['state'] = SecureRandom.hex(12)
        req.params['duration'] = 'permanent'
        req.params['scope'] = 'identity edit flair history modconfig\
        modflair modlog modposts modwiki mysubreddits privatemessages\
        read report save submit subscribe vote wikiedit wikiread'
      end
    end
  end
end
