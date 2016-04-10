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
          params = {}
          params[:query] = query
          data = request_data('/api/subreddits_by_topic', :get, params)
          data.map { |subreddit| subreddit[:name] }
        end
      end
    end
  end
end
