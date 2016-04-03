require_relative 'thing'
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
    # @!attribute [r] link_karma
    #   @return [Integer] Returns the link karma of the user.
    # @!attribute [r] comment_karma
    #   @return [Integer] Returns the comment karma of the user.
    class User < Thing
      include Thing::Createable
      include Thing::Refreshable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Web/Installed/Script] The client object.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc
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

      # @!group Listings
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
      # @option params :sort [String] The sorting algorithm [hot, new, top,
      #   controversial]
      # @option params :t [String] The time for the relevance sort [hour, day,
      #   week, month, year, all]
      # @option params :username [String] The username of an existing user.
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @return [NeonRAW::Objects::Listing] Returns the listing object.
      %w(overview comments submitted gilded upvoted downvoted
         hidden saved).each do |type|
        define_method :"get_#{type}" do |params = { limit: 25 }|
          path = "/user/#{name}/#{type}/.json"
          @client.send(:build_listing, path, params)
        end
      end
      # @!endgroup

      # Give gold to a user.
      # @!method give_gold(months)
      # @param months [1..36] The number of months worth of gold to give.
      def give_gold(months)
        params = {}
        params[:months] = months
        @client.request_data("/api/v1/gold/give/#{name}", :post, params)
        refresh!
      end

      # Send a PM to a user.
      # @!method message(text, subject, opts = {})
      # @param text [String] The text body of the message.
      # @param subject [String] The subject of the message (100 characters
      #   maximum).
      # @param opts [Hash] Optional parameters.
      # @option opts :from_subreddit [String] The subreddit to send the message
      #   from.
      # @return [Hash<Array>] Returns a list of errors.
      def message(text, subject, opts = {})
        params = {}
        params[:api_type] = 'json'
        params[:from_sr] = opts[:from_subreddit]
        params[:text] = text
        params[:subject] = subject
        params[:to] = name
        @client.request_data('/api/compose', :post, params)[:json]
      end
    end
  end
end
