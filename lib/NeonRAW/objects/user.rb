# rubocop:disable Metrics/MethodLength

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
          alias_method :friend?, :is_friend
          alias_method :gold?, :is_gold
          alias_method :moderator?, :is_mod
          alias_method :verified_email?, :has_verified_email
          alias_method :hide_from_robots?, :hide_from_robots
        end
      end

      # Fetches a listing from a user.
      # @!method get_overview(params = { limit: 25 })
      # @!method get_comments(params = { limit: 25 })
      # @!method get_submitted(params = { limit: 25 })
      # @!method get_gilded(params = { limit: 25 })
      # @!method get_upvoted(params = { limit: 25 })
      # @!method get_downvoted(params = { limit: 25 })
      # @!method get_hidden(params = { limit: 25 })
      # @!method get_saved(params = { limit: 25 })
      # @param params [Hash] The parameters for the request.
      # @option params :show [String] Show a listing type [overview, comments,
      #   submitted, gilded, upvoted, downvoted, hidden, saved]
      # @option params :sort [String] The sorting algorithm [hot, new top,
      #   controversial]
      # @option params :t [String] The time for the relevance sort [hour, day,
      #   week, month, year, all]
      # @option params :username [String] The username of an existing user.
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [Integer] The number of listing items to fetch.
      # @return [NeonRAW::Objects::Listing] Returns the listing object.
      %w(overview comments submitted gilded upvoted downvoted
         hidden saved).each do |type|
        define_method :"get_#{type}" do |params = { limit: 25 }|
          path = "/user/#{name}/#{type}/.json"
          @client.send(:build_listing, path, params)
        end
      end
    end
  end
end
