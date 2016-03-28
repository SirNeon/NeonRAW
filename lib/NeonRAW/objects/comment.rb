module NeonRAW
  module Objects
    # le comment object
    class Comment
      def initialize(data)
        data.each do |key, value|
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end
    end
  end
end
