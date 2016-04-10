module NeonRAW
  module Clients
    class Base
      # Utilities for the base client.
      module Utilities
        # Search for a subreddit.
        # @!method find_subreddit(query, opts = {})
        # @param query [String] The name to search for (50 characters maximum).
        # @param opts [Hash] Optional parameters.
        # @option opts :exact [Boolean] Whether or not to match only the exact
        #   query.
        # @option opts :include_nsfw [Boolean] Whether or not to include NSFW
        #   subreddits.
        def find_subreddit(query, opts = {})
          params = {}
          params[:exact] = opts[:exact]
          params[:include_over_18] = opts[:include_nsfw]
          params[:query] = query
          request_data('/api/search_reddit_names', :post, params)
        end
      end
    end
  end
end
