module NeonRAW
  module Objects
    # le user object
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
