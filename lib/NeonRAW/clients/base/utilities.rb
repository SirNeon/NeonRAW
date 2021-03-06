module NeonRAW
  module Clients
    class Base
      # Utilities for the base client.
      module Utilities
        # Search for subreddits.
        # @!method find_subreddits(query)
        # @param query [String] The name to search for (50 characters maximum).
        # @return [Array<String>] Returns the list of subreddits.
        def find_subreddits(query)
          params = { query: query }
          data = request_data('/api/subreddits_by_topic', :get, params)
          data.map { |subreddit| subreddit[:name] }
        end

        # Fetches subreddits.
        # @!method popular(params = { limit: 25 })
        # @!method new(params = { limit: 25 })
        # @!method gold(params = { limit: 25 })
        # @!method defaults(params = { limit: 25 })
        # @param params [Hash] The parameters.
        # @option params :after [String] Fullname of the next data block.
        # @option params :before [String] Fullname of the previous data block.
        # @option params :count [Integer] The number of items already in the
        #   listing.
        # @option params :limit [1..1000] The number of listing items to fetch.
        # @option params :show [String] Literally the string 'all'.
        # @return [NeonRAW::Objects::Listing] Returns a listing of all the
        #   subreddits.
        %w[popular new gold defaults].each do |type|
          define_method :"#{type}" do |params = { limit: 25 }|
            type.chop! if type == 'defaults'
            build_listing("/subreddits/#{type}", params)
          end
        end

        # Flattens comment trees into a single array.
        # @!method flatten_tree(comments)
        # @param comments [Array] A list of comments to be checked for replies
        #   to
        #   flatten.
        # @return [Array] Returns a list of the flattened comments.
        def flatten_tree(comments)
          flattened = []
          stack = comments.dup
          until stack.empty?
            comment = stack.shift
            if comment.is_a?(Objects::Comment) # MoreComments can be mixed in.
              replies = comment.replies
              stack = replies + stack unless replies.nil?
            end
            flattened << comment
          end
          flattened
        end

        # Fetches a list of wiki pages from Reddit.
        # @!method wikipages
        # @return [Array<String>] Returns a list of wiki pages.
        def wikipages
          request_data('/wiki/pages', :get)[:data]
        end

        # Streams listing items continuously.
        # @!method stream(path, params)
        # @param path [String] The API path for the listing you want streamed.
        # @param params [Hash] The optional parameters for the request.
        # @return [Enumerator] Returns an enumerator for the streamed data.
        def stream(path, params)
          Enumerator.new do |data_stream|
            before = params[:before]
            loop do
              params[:before] = before
              listing = build_listing(path, params)
              listing.each { |thing| data_stream << thing }
              before = listing.first.name unless listing.empty?
              sleep(1)
            end
          end
        end

        # Get info on a link/comment/subreddit.
        # @!method info(params = {})
        # @param params [Hash] The parameters.
        # @option params :name [String] The fullname of the thing.
        # @option params :url [String] The URL of the thing.
        # @return [NeonRAW::Objects::Listing] Returns a listing with the items.
        # @note :name and :url can take multiple fullnames separated by commas.
        # @see https://www.reddit.com/dev/api#fullnames
        def info(params = {})
          params[:id] = params[:name]
          params.delete(:name)
          build_listing('/api/info', params)
        end
        private :stream
      end
    end
  end
end
