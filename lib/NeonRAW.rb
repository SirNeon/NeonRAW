# rubocop:disable Style/FileName
require 'NeonRAW/version'
require 'NeonRAW/clients/installed'
require 'NeonRAW/clients/script'
require 'NeonRAW/clients/web'
require 'NeonRAW/errors'

# The main module.
module NeonRAW
  # Creates the Installed client.
  # @param creds [Hash] The credentials to create the client with.
  # @option creds :client_id [String] The client_id of the app.
  # @option creds :redirect_uri [String] The redirect_uri of the app.
  # @option creds :user_agent [String] The user_agent of the app.
  # @return [NeonRAW::Clients::Installed] Returns the Installed client.
  def self.installed(creds)
    %i[client_id redirect_uri].each do |param|
      raise Errors::InvalidCredentials if creds[param].nil?
    end
    Clients::Installed.new(creds)
  end

  # Creates the Script client.
  # @param creds [Hash] The credentials to create the client with.
  # @option creds :username [String] The username of the user.
  # @option creds :password [String] The password of the user.
  # @option creds :client_id [String] The client_id of the app.
  # @option creds :secret [String] The secret of the app.
  # @option creds :user_agent [String] The user_agent of the app.
  # @option creds :redirect_uri [String] The redirect_uri (defaults to
  #   http://127.0.0.1:).
  # @return [NeonRAW::Clients::Script] Returns the Script client.
  def self.script(creds)
    %i[username password client_id secret].each do |param|
      raise Errors::InvalidCredentials if creds[param].nil?
    end
    Clients::Script.new(creds)
  end

  # Creates the Web client.
  # @param creds [Hash] The credentials to create the client with.
  # @option creds :client_id [String] The client_id of the app.
  # @option creds :secret [String] The secret of the app.
  # @option creds :redirect_uri [String] The redirect_uri of the app.
  # @option creds :user_agent [String] The user_agent of the app.
  # @return [NeonRAW::Clients::Web] Returns the Web client.
  def self.web(creds)
    %i[client_id secret redirect_uri].each do |param|
      raise Errors::InvalidCredentials if creds[param].nil?
    end
    Clients::Web.new(creds)
  end
end
