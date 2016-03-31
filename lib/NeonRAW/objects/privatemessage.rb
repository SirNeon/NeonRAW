require_relative 'thing'

module NeonRAW
  module Objects
    # le PrivateMessage object
    class PrivateMessage < Thing
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end
    end
  end
end
