require_relative 'thing'

module NeonRAW
  module Objects
    # le inbox comment object
    class InboxComment < Thing
      include Thing::Createable
      include Thing::Inboxable
      include Thing::Moderateable
      include Thing::Repliable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc
          self.class.send(:attr_reader, key)
        end
      end
    end
  end
end
