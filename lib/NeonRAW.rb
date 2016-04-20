# rubocop:disable Style/FileName
require 'NeonRAW/version'
require 'NeonRAW/clients/installed'
require 'NeonRAW/clients/script'
require 'NeonRAW/clients/web'

# The main module.
module NeonRAW
  # Creates the Installed client.
  # @param client_id [String] The client_id of the app.
  # @param redirect_uri [String] The redirect_uri of the app.
  # @param opts [Hash] Optional parameters.
  # @option opts :user_agent [String] The user_agent of the app.
  # @return [NeonRAW::Clients::Installed] Returns the Installed client.
  def self.installed(client_id, redirect_uri, opts = {})
    Clients::Installed.new(client_id, redirect_uri, opts)
  end

  # Creates the Script client.
  # @param username [String] The username of the user.
  # @param password [String] The password of the user.
  # @param client_id [String] The client_id of the app.
  # @param secret [String] The secret of the app.
  # @param opts [Hash] Optional parameters.
  # @option opts :user_agent [String] The user_agent of the app.
  # @option opts :redirect_uri [String] The redirect_uri (defaults to
  #   http://127.0.0.1:).
  # @return [NeonRAW::Clients::Script] Returns the Script client.
  def self.script(username, password, client_id, secret, opts = {})
    Clients::Script.new(username, password, client_id, secret, opts)
  end

  # Creates the Web client.
  # @param client_id [String] The client_id of the app.
  # @param secret [String] The secret of the app.
  # @param redirect_uri [String] The redirect_uri of the app.
  # @param opts [Hash] Optional parameters.
  # @option opts :user_agent [String] The user_agent of the app.
  # @return [NeonRAW::Clients::Web] Returns the Web client.
  def self.web(client_id, secret, redirect_uri, opts = {})
    Clients::Web.new(client_id, secret, redirect_uri, opts)
  end
end
