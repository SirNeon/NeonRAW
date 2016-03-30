require 'typhoeus'
require 'json'
require_relative '../objects/subreddit'
require_relative '../objects/user'
require_relative '../objects/me'
require_relative '../objects/access'
require_relative '../error'

module NeonRAW
  # The underlying base for the client
  class Base
    include Error

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
    # @!method request_data
    # @param path [String] The API path to connect to.
    # @param meth [String] The request method to use.
    # @param params [Hash] Parameters for the request.
    # @return [Hash] Returns the parsed JSON as a hash containing
    #   the data.
    def request_data(path, meth, params = {})
      refresh_access! if @access.expired?
      data = api_connection(path, meth, params)
      JSON.parse(data.body, symbolize_names: true)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # Creates the listing object.
    # @!method build_listing(path, params)
    # @param path [String] The API path for the listing.
    # @param params [Hash] The parameters for the request.
    # @return [NeonRAW::Objects::Listing] Returns the Listing object.
    def build_listing(path, params)
      data_arr = []
      until data_arr.length == params[:limit]
        data = request_data(path, :get, params)
        params[:after] = data[:data][:after]
        params[:before] = data[:data][:before]
        data[:data][:children].each do |item|
          if item[:kind] == 't3'
            data_arr << Objects::Submission.new(self, item[:data])
          elsif item[:kind] == 't1'
            data_arr << Objects::Comment.new(self, item[:data])
          end
          break if data_arr.length == params[:limit]
        end
        break if params[:after].nil?
      end
      listing = Objects::Listing.new(params[:after], params[:before])
      data_arr.each { |submission| listing << submission }
      listing
    end

    def get_subreddit(name)
      data = request_data("/r/#{name}/about.json", :get)[:data]
      Objects::Subreddit.new(self, data)
    end

    def get_user(name)
      data = request_data("/user/#{name}/about.json", :get)[:data]
      Objects::User.new(self, data)
    end

    def me
      data = request_data('/api/v1/me', 'get')
      Objects::Me.new(self, data)
    end
    private :build_listing
  end
end
