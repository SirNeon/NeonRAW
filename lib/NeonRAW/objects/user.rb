require_relative 'thing'
require_relative 'trophy'

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
      # @param client [NeonRAW::Clients::Script] The client object.
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
      # @!method overview(params = { limit: 25 })
      # @!method comments(params = { limit: 25 })
      # @!method submitted(params = { limit: 25 })
      # @!method gilded(params = { limit: 25 })
      # @!method upvoted(params = { limit: 25 })
      # @!method downvoted(params = { limit: 25 })
      # @!method hidden(params = { limit: 25 })
      # @!method saved(params = { limit: 25 })
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
        define_method :"#{type}" do |params = { limit: 25 }|
          path = "/user/#{name}/#{type}/.json"
          @client.send(:build_listing, path, params)
        end
      end
      # @!endgroup

      # Give gold to a user.
      # @!method give_gold(months)
      # @param months [1..36] The number of months worth of gold to give.
      def give_gold(months)
        params = { months: months }
        @client.request_data("/api/v1/gold/give/#{name}", :post, params)
        refresh!
      end

      # Send a PM to a user.
      # @!method message(subject, text, opts = {})
      # @param subject [String] The subject of the message (100 characters
      #   maximum).
      # @param text [String] The text body of the message.
      # @param opts [Hash] Optional parameters.
      # @option opts :from_subreddit [String] The subreddit to send the message
      #   from.
      def message(subject, text, opts = {})
        params = { api_type: 'json', from_sr: opts[:from_subreddit], text: text,
                   subject: subject, to: name }
        @client.request_data('/api/compose', :post, params)
      end

      # Fetches the user's multireddits.
      # @!method multireddits
      # @return [Array<NeonRAW::Objects::MultiReddit>] Returns a list of
      #   multireddits.
      def multireddits
        data_arr = []
        params = { expand_srs: false }
        data = @client.request_data("/api/multi/user/#{name}", :get, params)
        data.each do |multireddit|
          data_arr << MultiReddit.new(@client, multireddit[:data])
        end
        data_arr
      end

      # Add the user to your friends list.
      # @!method friend
      def friend
        body = { 'name' => name }.to_json
        @client.request_data("/api/v1/me/friends/#{name}", :put, {}, body)
      end

      # Remove the user from your friends list.
      # @!method unfriend
      def unfriend
        params = { id: name }
        @client.request_nonjson("/api/v1/me/friends/#{name}", :delete, params)
      end

      # Fetches the user's trophies.
      # @!method trophies
      # @return [Array<NeonRAW::Objects::Trophy>] Returns a list of trophies.
      def trophies
        data_arr = []
        path = "/api/v1/user/#{name}/trophies"
        data = @client.request_data(path, :get)[:data]
        data[:trophies].each do |trophy|
          data_arr << Trophy.new(trophy[:data])
        end
        data_arr
      end
    end
  end
end
