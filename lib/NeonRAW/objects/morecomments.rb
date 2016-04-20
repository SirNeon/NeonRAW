require_relative 'comment'

module NeonRAW
  module Objects
    # The MoreComments object.
    class MoreComments
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end

      # Expands the MoreComments object.
      # @!method expand(subreddit)
      # @param subreddit [String] The name of the subreddit where the
      #   MoreComments object resides.
      # @return [Array] Returns a list of the comments that were expanded.
      def expand(subreddit)
        comments = []
        params = { id: children.map { |the_id| 't1_' + the_id }.join(',') }
        # /api/morechildren is buggy shit. This is better.
        data = @client.request_data("/r/#{subreddit}/api/info", :get, params)
        data[:data][:children].each do |comment|
          comments << Comment.new(@client, comment[:data])
        end
        comments
      end
    end
  end
end
