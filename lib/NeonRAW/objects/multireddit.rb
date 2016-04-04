require_relative 'thing'

module NeonRAW
  module Objects
    # le multireddit object
    class MultiReddit < Thing
      include Thing::Createable
      include Thing::Refreshable

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc || key == :subreddits
          self.class.send(:attr_reader, key)
        end
      end

      # Fetches a list of subreddits in the multireddit.
      # @!method subreddits
      # @return [Array<String>] Returns a list of subreddit display_names.
      def subreddits
        subreddits = @subreddits || []
        subreddits.map { |subreddit| subreddit[:name] }
      end
    end
  end
end
