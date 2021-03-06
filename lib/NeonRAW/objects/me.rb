require_relative 'user'
require_relative 'trophy'
require_relative 'multireddit'
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
# rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

module NeonRAW
  # Objects module.
  module Objects
    # The me object.
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
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client
      #   object.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data[:username] = data.delete(:name) # this is for consistency
        data[:name] = 't2_' + data[:id]
        data.each do |key, value|
          # for consistency, empty strings/arrays/hashes are set to nil
          # because most of the keys returned by Reddit are nil when they
          # don't have a value, besides a few
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if %i[created created_utc].include?(key)
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

      # @!group Listings
      # Fetches your private messages.
      # @!method messages(params = { limit: 25 })
      # @!method inbox(params = { limit: 25 })
      # @!method unread(params = { limit: 25 })
      # @!method sent(params = { limit: 25 })
      # @param params [Hash] Optional parameters.
      # @option params :mark [Boolean] Whether or not to remove the orangered
      #   from your inbox.
      # @option params :after [String] Fullname of the next data block.
      # @option params :before [String] Fullname of the previous data block
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns a listing with all your PMs.
      %w[messages inbox unread sent].each do |type|
        define_method :"#{type}" do |params = { limit: 25 }|
          @client.send(:build_listing, "/message/#{type}", params)
        end
      end

      # Fetches your modmail.
      # @!method modmail(params = { limit: 25 })
      # @param params [Hash] The parameters.
      # @option params :after [String] Fullname of the next data block.
      # @option params :before [String] Fullname of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns a listing with all your
      #   modmails.
      def modmail(params = { limit: 25 })
        @client.send(:build_listing, '/message/moderator', params)
      end

      # Fetches your subreddits.
      # @!method subscribed(params = { limit: 25 })
      # @!method contributed(params = { limit: 25 })
      # @!method moderated(params = { limit: 25 })
      # @param params [Hash] The parameters.
      # @option params :after [String] Fullname of the next data block.
      # @option params :before [String] Fullname of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns a listing with all your
      #   subreddits.
      %w[subscribed contributed moderated].each do |type|
        define_method :"#{type}" do |params = { limit: 25 }|
          type = 'subscriber' if type == 'subscribed'
          type = 'contributor' if type == 'contributed'
          type = 'moderator' if type == 'moderated'
          @client.send(:build_listing, "/subreddits/mine/#{type}", params)
        end
      end
      # @!endgroup

      # Fetches your karma breakdown.
      # @!method karma_breakdown
      # @return [Array<Hash<String, Integer, Integer>>] Returns a list with your
      #   karma distribution in it.
      def karma_breakdown
        data = @client.request_data('/api/v1/me/karma', :get)[:data]
        # done for consistency
        data.each { |subreddit| subreddit[:subreddit] = subreddit.delete(:sr) }
        data
      end

      # Fetches your preferences.
      # @!method prefs
      # @return [Hash] Returns your account preferences.
      def prefs
        @client.request_data('/api/v1/me/prefs', :get)
      end

      # Fetches your trophies.
      # @!method trophies
      # @return [Array<NeonRAW::Objects::Trophy>] Returns a list of trophies.
      def trophies
        data = @client.request_data('/api/v1/me/trophies', :get)[:data]
        data[:trophies].map { |trophy| Trophy.new(trophy[:data]) }
      end

      # Fetches your friends.
      # @!method friends(params = { limit: 25 })
      # @param params [Hash] The parameters for the request.
      # @option params :after [String] The fullname of a thing.
      # @option params :before [String] The fullname of a thing.
      # @option params :count [Integer] The number of items fetch already.
      # @option params :limit [1..100] The number of items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [Array<Hash<Time, String, String>>] Returns the list of your
      #   friends.
      def friends(params = { limit: 25 })
        data = @client.request_data('/prefs/friends', :get, params)
        data[0][:data][:children].each do |friend| # done for consistency
          friend[:date] = Time.at(friend[:date])
          friend[:username] = friend.delete(:name)
          friend[:name] = friend.delete(:id)
        end
        data[0][:data][:children].map { |friend| friend }
      end

      # Fetches your blocked users.
      # @!method blocked(params = { limit: 25 })
      # @param params [Hash] The parameters for the request.
      # @option params :after [String] The fullname of a thing.
      # @option params :before [String] The fullname of a thing.
      # @option params :count [Integer] The number of items fetch already.
      # @option params :limit [1..100] The number of items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [Array<Hash<Time, String, String>>] Returns the list of your
      #   blocked users.
      def blocked(params = { limit: 25 })
        data = @client.request_data('/prefs/blocked', :get, params)
        data[:data][:children].each do |blocked| # done for consistency
          blocked[:date] = Time.at(blocked[:date])
          blocked[:username] = blocked.delete(:name)
          blocked[:name] = blocked.delete(:id)
        end
        data[:data][:children].map { |blocked| blocked }
      end

      # Mark all your messages as "read."
      # @!method read_all_messages!
      def read_all_messages!
        @client.request_nonjson('/api/read_all_messages', :post)
      end

      # Fetches your multireddits.
      # @!method multireddits
      # @return [Array<NeonRAW::Objects::MultiReddit>] Returns a list of
      #   multireddits.
      def multireddits
        params = { expand_srs: false }
        data = @client.request_data('/api/multi/mine', :get, params)
        data.map { |multireddit| MultiReddit.new(@client, multireddit[:data]) }
      end

      # Goes through and edits then deletes your post history. Defaults to
      # 2 weeks.
      # @!method purge(queue, params = {})
      # @param queue [Symbol] The queue you want to get your posts from
      #   [overview, submitted, comments, upvoted, downvoted, hidden, saved,
      #   giled]
      # @param params [Hash] The additional parameters.
      # @option params :edit [String] The text to edit your posts with.
      # @option params :blacklist [Array<String>] Subreddits to avoid purging
      #   from.
      # @option params :whitelist [Array<String>] Subreddits to purge.
      # @option params :sort [String] The sort of the data (defaults to new)
      #   [new, hot, top, controversial].
      # @option params :hours [Integer] The number of hours to go back from.
      # @option params :days [Integer] The number of days to go back from.
      # @option params :weeks [Integer] The number of weeks to go back from.
      # @option params :months [Integer] The number of months to go back from.
      # @option params :years [Integer] The number of years to go back from.
      def purge(queue, params = {})
        params[:edit] = '.' if params[:edit].nil?
        params[:blacklist] = [] if params[:blacklist].nil?
        params[:whitelist] = ['*'] if params[:whitelist].nil?
        whitelist = params[:whitelist]
        params[:age] = max_age(params)
        items = send(:"#{queue}", sort: params[:sort] || 'new', limit: 1000)
        items.each do |item|
          next if params[:blacklist].include?(item.subreddit)
          next if item.created < params[:age]
          next unless whitelist.include?(item.subreddit) || whitelist[0] == '*'
          if item.is_a?(Submission)
            item.edit! params[:edit] if item.selfpost?
          else
            item.edit! params[:edit]
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
