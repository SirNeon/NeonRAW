require 'typhoeus'
require 'json'
require_relative 'base/listing'
require_relative 'base/objectbuilder'
require_relative 'base/utilities'
require_relative '../errors'

module NeonRAW
  module Clients
    # The underlying base for the client
    class Base
      include Base::Listings
      include Base::ObjectBuilder
      include Base::Utilities
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
      # @param opts [Hash] Optional parameters for the request body.
      # @return [Typhoeus::Response] Returns the response.
      def api_connection(path, meth, params, opts = {})
        response = Typhoeus::Request.new(
          'https://oauth.reddit.com' + path,
          method: meth,
          body: opts,
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
      # @param opts [Hash] Optional parameters for methods that send stuff
      #   via the request body.
      # @return [Hash] Returns the parsed JSON containing the response data.
      def request_data(path, meth, params = {}, opts = {})
        refresh_access! if @access.expired?
        response = api_connection(path, meth, params, opts)
        data = JSON.parse(response.body, symbolize_names: true)
        handle_data_errors(data)
        data
      end

      # Requests non-JSON data from Reddit.
      # @!method request_nonjson(path, meth, params = {}, oyts = {})
      # @param path [String] The API path to connect to.
      # @param meth [Symbol] The request method to use.
      # @param params [Hash] Parameters for the request.
      # @param opts [Hash] Optional parameters for methods that send stuff
      #   via the request body.
      def request_nonjson(path, meth, params = {}, opts = {})
        refresh_access! if @access.expired?
        api_connection(path, meth, params, opts).body
      end
    end
  end
end
