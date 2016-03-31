module NeonRAW
  module Objects
    class Thing
      # Methods for things that can be refreshed.
      module Refreshable
        # Refreshes the data of a comment/submission/subreddit object.
        # @!method refresh!
        def refresh!
          params = {}
          params[:id] = name
          data = @client.request_data("/r/#{subreddit}/api/info", :get, params)
          data[:data].each do |key, value|
            instance_variable_set(:"@#{key}", value)
          end
        end
      end
    end
  end
end
