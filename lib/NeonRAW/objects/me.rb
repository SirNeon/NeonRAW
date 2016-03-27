module NeonRAW
  module Objects
    # le me object
    # @!attribute [r] employee?
    #   @return [Boolean] Returns whether or not you're a Reddit
    #     employee.
    # @!attribute [r] mail?
    #   @return [Boolean] Returns whether or not you've got mail.
    # @!attribute [r] suspended?
    #   @return [Boolean] Returns whether or not your account is
    #     suspended.
    # @!attribute [r] modmail?
    #   @return [Boolean] Returns whether or not you've got modmail.
    # @!attribute [r] beta?
    #   @return [Boolean] Returns whether or not you're opted into
    #     beta testing.
    # @!attribute [r] over_18?
    #   @return [Boolean] Returns whether or not you can view adult
    #     content.
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
    class Me
      # rubocop:disable Metrics/MethodLength
      def initialize(data)
        data.each do |key, value|
          self.class.send(:define_method, key) do
            instance_variable_set("@#{key}", value)
          end
        end
        class << self
          alias_method :employee?, :is_employee
          alias_method :mail?, :has_mail
          alias_method :hide_from_robots?, :hide_from_robots
          alias_method :suspended?, :is_suspended
          alias_method :modmail?, :has_mod_mail
          alias_method :beta?, :in_beta
          alias_method :over_18?, :over_18
          alias_method :gold?, :is_gold
          alias_method :moderator?, :is_mod
          alias_method :verified_email?, :has_verified_email
        end
      end
    end
  end
end
