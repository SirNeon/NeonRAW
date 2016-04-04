require_relative '../objects/submission'
require_relative '../objects/listing'
require_relative '../objects/comment'
require_relative '../objects/thing'
require_relative 'subreddit/flair'
require_relative 'subreddit/moderation'
# rubocop:disable Metrics/MethodLength, Metrics/AbcSize

module NeonRAW
  module Objects
    # le subreddit object
    # @!attribute [r] subscribed?
    #   @return [Boolean] Returns whether or not you're subscribed
    #     to the subreddit.
    # @!attribute [r] approved_submitter?
    #   @return [Boolean] Returns whether or not you're an approved
    #     submitter to the subreddit.
    # @!attribute [r] moderator?
    #   @return [Boolean] Returns whether or not you're a moderator
    #     of the subreddit.
    # @!attribute [r] im_banned?
    #   @return [Boolean] Returns whether or not you're banned from
    #     the subreddit.
    # @!attribute [r] collapse_deleted_comments?
    #   @return [Boolean] Returns whether or not the subreddit
    #     collapses deleted comments.
    # @!attribute [r] nsfw?
    #   @return [Boolean] Returns whether or not the subreddit is
    #     marked for adult content.
    # @!attribute [r] muted?
    #   @return [Boolean] Returns whether or not you're muted from
    #     the subreddit's modmail.
    # @!attribute [r] quarantined?
    #   @return [Boolean] Returns whether or not the subreddit is
    #     quarantined.
    # @!attribute [r] public_traffic?
    #   @return [Boolean] Returns whether or not the subreddit made
    #     their traffic stats public.
    # @!attribute [r] theme_enabled?
    #   @return [Boolean] Returns whether or not you have the
    #     subreddit theme enabled.
    # @!attribute [r] wiki_enabled?
    #   @return [Boolean] Returns whether or not the subreddit has
    #     its wiki enabled.
    # @!attribute [r] hide_ads?
    #   @return [Boolean] Returns whether or not the subreddit hides
    #     ads.
    # @!attribute [r] banner_img
    #   @return [String, nil] Returns a string container a link to the
    #     banner image or nil if there is none.
    # @!attribute [r] submit_text_html
    #   @return [String, nil] Returns the text with HTML included in the
    #     thread submission page or nil if there is none..
    # @!attribute [r] submit_text
    #   @return [String, nil] Returns the text included in the thread
    #     submission page or nil if there is none.
    # @!attribute [r] display_name
    #   @return [String] Returns the display name of the subreddit.
    # @!attribute [r] header_img
    #   @return [String, nil] Returns the link to the header image
    #     or nil if there is none.
    # @!attribute [r] sidebar_html
    #   @return [String, nil] Returns the subreddit's sidebar text
    #     with HTML or nil if there is none..
    # @!attribute [r] title
    #   @return [String] Returns the subreddit's title.
    # @!attribute [r] public_description
    #   @return [String, nil] Returns the subreddit's public description or nil
    #     if there is none..
    # @!attribute [r] public_description_html
    #   @return [String, nil] Returns the subreddit's public description
    #     with HTML included or nil if there is none.
    # @!attribute [r] suggested_comment_sort
    #   @return [String, nil] Returns the subreddit's suggested
    #     comment sort or nil if there isn't one [hot, top, new,
    #     old, controversial, random]
    # @!attribute [r] submit_link_label
    #   @return [String, nil] Returns the subreddit's custom label
    #     for the submit link button or nil if there is none.
    # @!attribute [r] submit_text_label
    #   @return [String, nil] Returns the subreddit's custom label
    #     for the submit text button or nil if there is none.
    # @!attribute [r] header_title
    #   @return [String, nil] Returns the header title or nil if
    #     there is none.
    # @!attribute [r] sidebar
    #   @return [String] Returns the subreddit's sidebar text.
    # @!attribute [r] accounts_active
    #   @return [Integer] Returns the number of users online browsing
    #     the subreddit.
    # @!attribute [r] header_size
    #   @return [Array<Integer, Integer>, nil] Returns an array containing the
    #     header's dimensions or nil if there isn't one.
    # @!attribute [r] subscribers
    #   @return [Integer] Returns the number of subscribers the
    #     subreddit has.
    # @!attribute [r] lang
    #   @return [String] Returns the subreddit's primary language.
    # @!attribute [r] url
    #   @return [String] Returns the subreddit's URL.
    # @!attribute [r] comment_score_hide_mins
    #   @return [Integer] Returns the number of minutes that comment
    #     scores are hidden.
    # @!attribute [r] subreddit_type
    #   @return [String] Returns the type of subreddit [public,
    #     restricted, private, gold_restricted, archived].
    # @!attribute [r] submission_type
    #   @return [String] Returns the type of submissions allowed
    #     to be posted [any, link, self].
    class Subreddit < Thing
      include Thing::Createable
      include Thing::Refreshable
      include Flair
      include Moderation

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
          alias_method :subscribed?, :user_is_subscriber
          alias_method :approved_submitter?, :user_is_contributor
          alias_method :moderator?, :user_is_moderator
          alias_method :im_banned?, :user_is_banned
          alias_method :collapses_deleted_comments?, :collapse_deleted_comments
          alias_method :nsfw?, :over18
          alias_method :muted?, :user_is_muted
          alias_method :quarantined?, :quarantine
          alias_method :public_traffic?, :public_traffic
          alias_method :theme_enabled?, :user_sr_theme_enabled
          alias_method :wiki_enabled?, :wiki_enabled
          alias_method :hide_ads?, :hide_ads
          alias_method :sidebar, :description
          alias_method :sidebar_html, :description_html
        end
      end

      # Get info on a link/comment/subreddit.
      # @!method get_info(type, thing)
      # @param type [Symbol] The type of thing [id, url].
      # @param thing [String] Either a name or an URL.
      # @return [NeonRAW::Objects::Comment/Submission/Subreddit] Returns the
      #   object.
      def get_info(type, thing)
        params = {}
        params[type] = thing
        data = @client.request_data("/r/#{display_name}/api/info", :get, params)
        case data[:data][:children][0][:kind]
        when 't1' then Comment.new(@client, data[:data][:children][0][:data])
        when 't3' then Submission.new(@client, data[:data][:children][0][:data])
        when 't5' then Subreddit.new(@client, data[:data][:children][0][:data])
        end
      end

      # Submit a thread to the subreddit.
      # @!method submit(params = {})
      # @param params [Hash] The parameters.
      # @option params :text [String] The text of the submission (selfpost).
      # @option params :url [String] The URL of the submission (link post).
      # @option params :title [String] The title of the submission (300
      #   characters maximum).
      # @return [NeonRAW::Objects::Submission] Returns the submission object.
      def submit(params = {})
        params[:kind] = :self if params[:text]
        params[:kind] = :link if params[:url]
        params[:sr] = display_name
        response = @client.request_data('/api/submit', :post, params)
        # Seriously though, fucking convoluted data structures.
        submission_id = response[:jquery][10][3][0].split('/')[6]
        get_info(:id, 't3_' + submission_id)
      end

      # @!group Listings
      # Fetches a listing from the subreddit.
      # @!method get_hot(params = { limit: 25 })
      # @!method get_top(params = { limit: 25 })
      # @!method get_old(params = { limit: 25 })
      # @!method get_new(params = { limit: 25 })
      # @!method get_controversial(params = { limit: 25 })
      # @!method get_comments(param = { limit: 25 })
      # @param params [Hash] The parameters for the request.
      # @option params :t [String] Time for relevant sorting [hour, day, week,
      #   month, year, all]
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns the listing object.
      %w(hot top old new controversial comments).each do |type|
        define_method :"get_#{type}" do |params = { limit: 25 }|
          path = "/r/#{display_name}/#{type}/.json"
          @client.send(:build_listing, path, params)
        end
      end
      # @!endgroup
    end
  end
end
