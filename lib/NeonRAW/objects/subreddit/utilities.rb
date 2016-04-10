# rubocop:disable Metrics/AbcSize

module NeonRAW
  module Objects
    class Subreddit
      # Utilities for subreddits.
      module Utilities
        # Get info on a link/comment/subreddit.
        # @!method get_info(params = {})
        # @param params [Hash] The parameters.
        # @option params :id [String] The fullname of the thing.
        # @option params :url [String] The URL of the thing.
        # @return [NeonRAW::Objects::Comment/Submission/Subreddit] Returns the
        #   object.
        def get_info(params = {})
          path = "/r/#{display_name}/api/info"
          data = @client.request_data(path, :get, params)
          case data[:data][:children][0][:kind]
          when 't1'
            Comment.new(@client, data[:data][:children][0][:data])
          when 't3'
            Submission.new(@client, data[:data][:children][0][:data])
          when 't5'
            Subreddit.new(@client, data[:data][:children][0][:data])
          end
        end

        # Submit a thread to the subreddit.
        # @!method submit(params = {})
        # @param params [Hash] The parameters.
        # @option params :text [String] The text of the submission (selfpost).
        # @option params :url [String] The URL of the submission (link post).
        # @option params :title [String] The title of the submission (300
        #   characters maximum).
        # @return [NeonRAW::Objects::Submission] Returns the submission object.
        def submit(params = {})
          params[:kind] = :self if params[:text]
          params[:kind] = :link if params[:url]
          params[:sr] = display_name
          response = @client.request_data('/api/submit', :post, params)
          # Seriously though, fucking convoluted data structures.
          submission_id = response[:jquery][10][3][0].split('/')[6]
          get_info(id: 't3_' + submission_id)
        end

        # Gets recommended subreddits for the subreddit.
        # @!method recommended_subreddits(opts = {})
        # @param opts [Hash] Optional parameters.
        # @option opts :omit [String] A comma-separated list of subreddits to
        #   omit from the results.
        # @return [Array<String>] Returns a list of the recommended subreddits.
        def recommended_subreddits(opts = {})
          params = {}
          params[:omit] = opts[:omit]
          params[:srnames] = display_name
          path = "/api/recommend/sr/#{display_name}"
          data = @client.request_data(path, :get, params)
          data.map { |subreddit| subreddit[:sr_name] }
        end
      end
    end
  end
end
