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
          path = "/r/#{display_name}/api/info" if /t5_/ =~ name
          path = "/r/#{subreddit}/api/info" unless /t5_/ =~ name
          data = @client.request_data(path, :get, params)
          data[:data][:children][0][:data].each do |key, value|
            value = nil if ['', [], {}].include?(value)
            instance_variable_set(:"@#{key}", value)
          end
        end
      end
    end
  end
end
