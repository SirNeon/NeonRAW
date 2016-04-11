require_relative 'thing'

module NeonRAW
  module Objects
    # le rule object
    # @!attribute [r] kind
    #   @return [String] Returns the kind of rule.
    # @!attribute [r] description
    #   @return [String] Returns the description of the rule.
    # @!attribute [r] short_name
    #   @return [String] Returns the name of the rule.
    # @!attribute [r] created_utc
    #   @return [Time] Returns when the rule was created.
    # @!attribute [r] priority
    #   @return [Integer] Returns the priority of the rule.
    # @!attribute [r] description_html
    #   @return [String] Returns the description of the rule with HTML.
    class Rule < Thing
      include Thing::Createable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Web/Installed/Script] The client object.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created_utc
          self.class.send(:attr_reader, key)
        end
      end
    end
  end
end
