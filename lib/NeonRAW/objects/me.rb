require_relative 'user'

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
    # @!attribute [r] inbox_count
    #   @return [Integer] Returns the number of unread messages
    #     in your inbox.
    class Me < User
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
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
