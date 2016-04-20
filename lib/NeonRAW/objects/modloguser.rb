require_relative 'thing'

module NeonRAW
  module Objects
    # The modloguser object.
    # @!attribute [r] note
    #   @return [String, nil] Returns the reason for the banning or nil if there
    #     is none. This attribute is only available for the banned and
    #     wikibanned methods.
    # @!attribute [r] mod_permissions
    #   @return [Array<String>] Returns the mod permissions for the user. This
    #     attribute is only available for the moderators method.
    class ModLogUser < Thing
      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :date
          self.class.send(:attr_reader, key)
        end
      end

      # Gets the date of when the user was added to the list.
      # @!method date
      # @return [Time] Returns when the user was added to the list.
      def date
        Time.at(@date)
      end
    end
  end
end
