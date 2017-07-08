module NeonRAW
  module Objects
    class Subreddit
      # Utilities for subreddits.
      module Utilities
        # Submit a thread to the subreddit.
        # @!method submit(title, params = {})
        # @param title [String] The title of the submission (300
        #   characters maximum).
        # @param params [Hash] The parameters.
        # @option params :text [String] The text of the submission (selfpost).
        # @option params :url [String] The URL of the submission (link post).
        # @return [NeonRAW::Objects::Submission] Returns the submission object.
        # @note This method uses 2 API requests, as it calls #info since the
        #   JSON returned doesn't give you the submission data.
        def submit(title, params = {})
          params[:kind] = 'self' if params[:text]
          params[:kind] = 'link' if params[:url]
          params[:api_type] = 'json'
          params[:sr] = display_name
          params[:title] = title
          response = @client.request_data('/api/submit', :post, params)
          @client.info(name: response[:json][:data][:name]).first
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
        %w[subscribe unsubscribe].each do |type|
          define_method :"#{type}!" do
            params = { sr: name }
            params[:action] = 'sub' if type == 'subscribe'
            params[:action] = 'unsub' if type == 'unsubscribe'
            @client.request_data('/api/subscribe', :post, params)
            refresh!
          end
        end

        # Streams content from subreddits.
        # @!method stream(queue, params = { limit: 25 })
        # @param queue [Symbol] The queue to get data from [hot, top, new,
        #   controversial, gilded, comments]
        # @param params [Hash] The parameters for the request.
        # @option params :t [String] Time for relevant sorting [hour, day, week,
        #   month, year, all]
        # @option params :after [String] The name of the next data block.
        # @option params :before [String] The name of the previous data block.
        # @option params :count [Integer] The number of items already in the
        #   listing.
        # @option params :limit [1..1000] The number of items to fetch.
        # @option params :show [String] Literally the string 'all'.
        # @yield [NeonRAW::Objects::Comment/Submission] Yields listing items.
        # @return [Enumerator] Returns an enumerator for the streamed data.
        # @example Simple comment stream.
        #   client = NeonRAW.script(...)
        #   comments = client.subreddit(...).stream :comments
        #   comments.each do |comment|
        #     comment.reply 'world' if comment.body =~ /hello/i
        #   end
        def stream(queue, params = { limit: 25 })
          @client.send(:stream, "/r/#{display_name}/#{queue}", params)
        end

        # Returns data on the moderators of the subreddit.
        # @!method moderators
        # @return [Array<Hash<String, String, Array<String>, Float, String,
        #  String>>] Returns data on the moderators.
        def moderators
          path = "/r/#{display_name}/about/moderators"
          data = @client.request_data(path, :get)[:data][:children]
          data.each do |user|
            user[:username] = user.delete(:name)
            user[:name] = user.delete(:id) # this is for consistency
          end
          data
        end
      end
    end
  end
end
