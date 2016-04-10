# rubocop:disable Metrics/MethodLength, Metrics/AbcSize

module NeonRAW
  module Objects
    class Subreddit
      # Utilities for subreddits.
      module Utilities
        # Get info on a link/comment/subreddit.
        # @!method get_info(type, thing)
        # @param type [Symbol] The type of thing [id, url].
        # @param thing [String] Either a name or an URL.
        # @return [NeonRAW::Objects::Comment/Submission/Subreddit] Returns the
        #   object.
        def get_info(type, thing)
          params = {}
          params[type] = thing
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
          get_info(:id, 't3_' + submission_id)
        end

        # Gets recommended subreddits for the subreddit.
        # @!method recommended_subreddits(opts = {})
        # @param opts [Hash] Optional parameters.
        # @option opts :omit [String] A comma-separated list of subreddits to
        #   omit from the results.
        def recommended_subreddits(opts = {})
          params = {}
          params[:omit] = opts[:omit]
          params[:srnames] = display_name
          path = "/api/recommended/sr/#{display_name}"
          @client.request_data(path, :get, params)
        end
      end
    end
  end
end
