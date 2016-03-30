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
    #   @return [Time] Returns how long until the token expires.
    # @!attribute [r] expires_at
    #   @return [Time] Returns when the token expires.
    class Access
      def initialize(data)
        data.each do |key, value|
          instance_variable_set("@#{key}", value)
          self.class.send(:attr_reader, key)
        end
        # I have it expire 10 seconds early to give a small buffer
        # for requests to avoid getting those icky 401 errors.
        @expires_at = Time.now + 3590
      end

      # @!method expired?
      # @return [Boolean] Returns whether or not the token is expired.
      def expired?
        Time.now > @expires_at
      end
    end
  end
end
