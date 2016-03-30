module NeonRAW
  module Objects
    # le MoreComments object
    class MoreComments
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
