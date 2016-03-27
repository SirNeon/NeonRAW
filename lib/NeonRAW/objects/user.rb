module NeonRAW
  module Objects
    # le user object
    # @!attribute [r] friend?
    #   @return [Boolean] Returns whether or not the user is a friend.
    # @!attribute [r] gold?
    #   @return [Boolean] Returns whether or not the user has gold.
    # @!attribute [r] moderator?
    #   @return [Boolean] Returns whether or not the user is a
    #     moderator.
    # @!attribute [r] verified_email?
    #   @return [Boolean] Returns whether or not the user has a
    #     verified email.
    # @!attribute [r] hide_from_robots?
    #   @return [Boolean] Returns whether or not the user doesn't
    #     want web crawlers indexing their profile page.
    # @!attribute [r] name
    #   @return [String] Returns the user's name.
    # @!attribute [r] created
    #   @return [Float] Returns when the user's account was created
    #     (UNIX timestamp)
    # @!attribute [r] created_utc
    #   @return [Float] Returns when the user's account was created
    #     in UTC (UNIX timestamp).
    # @!attribute [r] link_karma
    #   @return [Integer] Returns the link karma of the user.
    # @!attribute [r] comment_karma
    #   @return [Integer] Returns the comment karma of the user.
    # @!attribute [r] id
    #   @return [String] Returns the id of the user.
    class User
      # rubocop:disable Metrics/MethodLength
      def initialize(data)
        data.each do |key, value|
          self.class.send(:define_method, key) do
            instance_variable_set(:"@#{key}", value)
          end
        end
        class << self
          alias_method :friend?, :is_friend
          alias_method :gold?, :is_gold
          alias_method :moderator?, :is_mod
          alias_method :verified_email?, :has_verified_email
          alias_method :hide_from_robots?, :hide_from_robots
        end
      end
    end
  end
end
