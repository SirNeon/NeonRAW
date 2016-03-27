module NeonRAW
  module Objects
    # le access object
    class Access
      def initialize(data)
        data.each do |key, value|
          self.class.send(:define_method, key) do
            instance_variable_set("@#{key}", value)
          end
        end
        @expires_in = Time.now + 3600
      end

      def expired?
        Time.now > @expires_in
      end
    end
  end
end
