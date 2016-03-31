require_relative 'user'
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength,
# rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

module NeonRAW
  # Objects module.
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
      # @!method initialize(client, data)
      # @param client [NeonRAW::Web/Installed/Script] The client object.
      # @param data [Hash] The object data.
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

      # Goes through and edits then deletes your post history. Defaults to
      # 2 weeks.
      # @!method purge(queue, params = {})
      # @param queue [Symbol] The queue you want to get your posts from
      #   [overview, submitted, comments, upvoted, downvoted, hidden, saved,
      #   giled]
      # @param params [Hash] The additional parameters.
      # @option params :edit [String] The text to edit your posts with.
      # @option params :blacklist [Array] Subreddits [String] to avoid purging
      #   from.
      # @option params :whitelist [Array] Subreddits [String] to purge.
      # @option params :hours [Integer] The number of hours to go back from.
      # @option params :days [Integer] The number of days to go back from.
      # @option params :weeks [Integer] The number of weeks to go back from.
      # @option params :months [Integer] The number of months to go back from.
      # @option params :years [Integer] The number of years to go back from.
      def purge!(queue, params = {})
        params[:edit] = '.' if params[:edit].nil?
        params[:blacklist] = [] if params[:blacklist].nil?
        params[:whitelist] = ['*'] if params[:whitelist].nil?
        whitelist = params[:whitelist]
        params[:age] = max_age(params)
        items = send(:"get_#{queue}", sort: 'new', limit: 1000)
        items.each do |item|
          next if params[:blacklist].include?(item.subreddit)
          break if item.created < params[:age]
          next unless whitelist.include?(item.subreddit) || whitelist[0] == '*'
          if item.is_a?(Submission)
            item.edit params[:edit] if item.selfpost?
          else
            item.edit params[:edit]
          end
          item.delete!
        end
      end

      # Fetches the max age of things to be purged.
      # @!method max_age(params)
      # @param params [Hash] The hours/days/weeks/months/years to go back from.
      def max_age(params)
        start = Time.now
        age = start
        age -= 3600 * params[:hours] unless params[:hours].nil?
        age -= 86_400 * params[:days] unless params[:days].nil?
        age -= 604_800 * params[:weeks] unless params[:weeks].nil?
        age -= 2_419_200 * params[:months] unless params[:months].nil?
        age -= 29_030_400 * params[:years] unless params[:years].nil?
        age -= (604_800 * 2) if age == start # defaults to 2 weeks
        age
      end
      private :max_age
    end
  end
end
