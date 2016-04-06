require 'typhoeus'
require 'json'
require_relative 'base/listing'
require_relative 'base/captcha'
require_relative 'base/objectsbuilder'
require_relative '../errors'

module NeonRAW
  module Clients
    # The underlying base for the client
    class Base
      include Base::Listings
      include Base::Captchas
      include Base::ObjectsBuilder
      include Errors

      # Creates headers for oAuth2 requests.
      # @!method api_headers
      # @return [Hash] Returns oAuth2 headers.
      def api_headers
        {
          'User-Agent' => @user_agent,
          'Authorization' => "bearer #{@access.access_token}"
        }
      end

      # Connects to Reddit for oAuth2 requests.
      # @!method api_connection(path, meth, params)
      # @param path [String] The API path.
      # @param meth [Symbol] The request method.
      # @param params [Hash] The parameters.
      # @return [Typhoeus::Response] Returns the response.
      def api_connection(path, meth, params)
        response = Typhoeus::Request.new(
          'https://oauth.reddit.com' + path,
          method: meth,
          headers: api_headers,
          params: params
        ).run
        error = assign_errors(response)
        fail error unless error.nil?
        handle_ratelimit(response.headers)
        response
      end

      # Makes the connection used to authorize the client.
      # @!method auth_connection(path, meth, params)
      # @param path [String] The API path.
      # @param meth [Symbol] The request method.
      # @param params [Hash] The parameters.
      # @return [Typhoeus::Response] Returns the response.
      def auth_connection(path, meth, params)
        response = Typhoeus::Request.new(
          'https://www.reddit.com' + path,
          method: meth,
          userpwd: "#{@client_id}:#{@secret}",
          headers: { 'User-Agent' => @user_agent },
          params: params
        ).run
        error = assign_errors(response)
        fail error unless error.nil?
        response
      end

      # Requests data from Reddit.
      # @!method request_data(path, meth, params = {})
      # @param path [String] The API path to connect to.
      # @param meth [Symbol] The request method to use.
      # @param params [Hash] Parameters for the request.
      # @return [Hash] Returns the parsed JSON as a hash containing
      #   the data.
      def request_data(path, meth, params = {})
        refresh_access! if @access.expired?
        response = api_connection(path, meth, params)
        data = JSON.parse(response.body, symbolize_names: true)
        handle_data_errors(data)
        data
      end

      # Requests non-JSON data from Reddit.
      # @!method request_nonjson(path, meth, params = {})
      # @param path [String] The API path to connect to.
      # @param meth [Symbol] The request method to use.
      # @param params [Hash] Parameters for the request.
      def request_nonjson(path, meth, params = {})
        refresh_access! if @access.expired?
        api_connection(path, meth, params).body
      end
    end
  end
end
