# rubocop:disable Style/FileName, Metrics/ParameterLists
require 'NeonRAW/version'
require 'NeonRAW/clients/script'

# le module
module NeonRAW
  TYPES = {
    script: Clients::Script
  }.freeze

  # Create a new client instance.
  # @!method self.new(type, username, password, client_id, secret, opts = {})
  # @param type [Symbol] The type of client to make [script, web, installed].
  # @param username [String] Your account's username.
  # @param password [String] Your account's password.
  # @param client_id [String] Your account's client_id.
  # @param secret [String] Your account's secret.
  # @param opts [Hash] Optional parameters.
  # @option opts :user_agent [String] The useragent for the client.
  # @option opts :redirect_uri [String] The redirect URI for the client.
  def self.new(type, username, password, client_id, secret, opts = {})
    TYPES[type].new(username, password, client_id, secret, opts)
  end
end
