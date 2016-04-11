require_relative 'thing'

module NeonRAW
  module Objects
    # le wikipage object
    class WikiPage
      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :revision_by
          self.class.send(:attr_reader, key)
        end
      end

      # The user who made the last revision to the wiki page.
      # @!method revised_by
      # @return [String] Returns the username of the user.
      def revised_by
        @revision_by[:name]
      end
    end
  end
end
