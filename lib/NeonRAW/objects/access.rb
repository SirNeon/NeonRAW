module NeonRAW
  module Objects
    # le access object
    # @!attribute [r] access_token
    #   @return [String] Returns the access token used for oAuth2.
    # @!attribute [r] token_type
    #   @return [String] Returns the type of the token (bearer)
    # @!attribute [r] scope
    #   @return [String] Returns the scope where the token is valid.
    # @!attribute [r] expires_in
    #   @return [Time] Returns when the token expires.
    class Access
      def initialize(data)
        data.each do |key, value|
          self.class.send(:define_method, key) do
            instance_variable_set("@#{key}", value)
          end
        end
        @expires_in = Time.now + 3600
      end

      # @!method expired?
      # @return [Boolean] Returns whether or not the token is expired.
      def expired?
        Time.now > @expires_in
      end
    end
  end
end
