module NeonRAW
  module Objects
    class Subreddit
      # Utilities for subreddits.
      module Utilities
        # Get info on a link/comment/subreddit.
        # @!method info(params = {})
        # @param params [Hash] The parameters.
        # @option params :name [String] The fullname of the thing.
        # @option params :url [String] The URL of the thing.
        # @return [NeonRAW::Objects::Comment/Submission/Subreddit] Returns the
        #   object.
        # @see https://www.reddit.com/dev/api#fullnames
        def info(params = {})
          params[:id] = params[:name]
          params.delete(:name)
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
        # @!method submit(title, params = {})
        # @param title [String] The title of the submission (300
        #   characters maximum).
        # @param params [Hash] The parameters.
        # @option params :text [String] The text of the submission (selfpost).
        # @option params :url [String] The URL of the submission (link post).
        # @return [NeonRAW::Objects::Submission] Returns the submission object.
        def submit(title, params = {})
          params[:kind] = 'self' if params[:text]
          params[:kind] = 'link' if params[:url]
          params[:sr] = display_name
          params[:title] = title
          response = @client.request_data('/api/submit', :post, params)
          # Seriously though, fucking convoluted data structures.
          submission_id = response[:jquery].last[3].first.split('/')[6]
          info(id: 't3_' + submission_id)
        end

        # Gets recommended subreddits for the subreddit.
        # @!method recommended_subreddits(opts = {})
        # @param opts [Hash] Optional parameters.
        # @option opts :omit [String] A comma-separated list of subreddits to
        #   omit from the results.
        # @return [Array<String>] Returns a list of the recommended subreddits.
        def recommended_subreddits(opts = {})
          params = { omit: opts[:omit], srnames: display_name }
          path = "/api/recommend/sr/#{display_name}"
          data = @client.request_data(path, :get, params)
          data.map { |subreddit| subreddit[:sr_name] }
        end

        # Toggle your subscription to the subreddit.
        # @!method subscribe!
        # @!method unsubscribe!
        %w(subscribe unsubscribe).each do |type|
          define_method :"#{type}!" do
            params = { sr: name }
            params[:action] = 'sub' if type == 'subscribe'
            params[:action] = 'unsub' if type == 'unsubscribe'
            @client.request_data('/api/subscribe', :post, params)
            refresh!
          end
        end
      end
    end
  end
end
