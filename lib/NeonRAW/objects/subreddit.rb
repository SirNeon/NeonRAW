require_relative '../objects/submission'
require_relative '../objects/listing'
require_relative '../objects/comment'
require_relative '../objects/thing'
# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
# rubocop:disable Style/AccessorMethodName, Metrics/LineLength

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

      # @!group Flair
      # Clears flair templates.
      # @!method clear_flair_templates(flair_type)
      # @param flair_type [Symbol] The type of flair [USER_FLAIR, LINK_FLAIR].
      def clear_flair_templates(flair_type)
        params = {}
        params[:api_type] = 'json'
        params[:flair_type] = flair_type
        path = "/r/#{display_name}/api/clearflairtemplates"
        @client.request_data(path, :post, params)
      end

      # Deletes a user's flair.
      # @!method delete_flair(username)
      # @param [String] The username of the user's whose flair will be deleted.
      def delete_flair(username)
        params = {}
        params[:api_type] = 'json'
        params[:name] = username
        path = "/r/#{display_name}/api/deleteflair"
        @client.request_data(path, :post, params)
      end

      # Delete a flair template.
      # @!method delete_flair_template(template_id)
      # @param template_id [String] The template's ID.
      def delete_flair_template(template_id)
        params = {}
        params[:api_type] = 'json'
        params[:flair_template_id] = template_id
        path = "/r/#{display_name}/api/deleteflairtemplate"
        @client.request_data(path, :post, params)
      end

      # Sets the flair on either a link or a user.
      # @!method set_flair(type, thing_name, text, css_class)
      # @param type [Symbol] The type of flair to set [user, link]
      # @param thing_name [String] Either the username or name of the link.
      # @param text [String] The flair text (64 characters max).
      # @param css_class [String] The CSS class of the flair.
      def set_flair(type, thing_name, text, css_class)
        params = {}
        params[:api_type] = 'json'
        params[:text] = text
        params[:css_class] = css_class
        if type == :user
          params[:name] = thing_name
        elsif type == :link
          params[:link] = thing_name
        end
        path = "/r/#{display_name}/api/flair"
        @client.request_data(path, :post, params)
      end

      # Configure the subreddit's flairs.
      # @!method flair_config(enabled, position, self_assign_enabled, link_flair_position, self_link_flair_assign)
      # @param enabled [Boolean] Enable/disable flair.
      # @param position [Symbol] Flair position [left, right].
      # @param self_assign_enabled [Boolean] Allow/disallow users to set their
      #   own flair.
      # @param link_flair_position [Symbol] Link flair position ['', left,
      #   right].
      # @param self_link_flair_assign [Boolean] Allow/disallow users to set
      #   their own link flair.
      def flair_config(enabled, position, self_assign_enabled,
                       link_flair_position, self_link_flair_assign)
        params = {}
        params[:api_type] = 'json'
        params[:flair_enabled] = enabled
        params[:flair_position] = position
        params[:flair_self_assign_enabled] = self_assign_enabled
        params[:link_flair_position] = link_flair_position
        params[:link_flair_self_assign_enabled] = self_link_flair_assign
        path = "/r/#{display_name}/api/flairconfig"
        @client.request_data(path, :post, params)
      end

      # Sets flairs for multiple users.
      # @!method set_many_flairs(flair_data)
      # @param flair_data [String] The flair data in CSV format. Format as such:
      #   User,flair text,CSS class.
      # @note This API can take up to 100 lines before it starts ignoring
      #   things. If the flair text and CSS class are both empty strings then
      #   it will clear the user's flair.
      # @todo Figure out how to properly format multiple CSV values.
      def set_many_flairs(flair_data)
        params = {}
        params[:flair_csv] = flair_data
        path = "/r/#{display_name}/api/flaircsv"
        @client.request_data(path, :post, params)
      end

      # Fetches a list of flairs.
      # @!method flairlist(params = { limit: 25 })
      # @param params [Hash] The parameters.
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the list.
      # @option params :limit [1..1000] The number of items to fetch.
      # @option params :name [String] The username of the user whose flair you
      #   want.
      # @option params :show [String] Literally the string 'all'.
      # @return [Hash<Array<Hash>>] Returns a list of the flairs.
      def flairlist(params = { limit: 25 })
        path = "/r/#{display_name}/api/flairlist"
        @client.request_data(path, :get, params)
      end

      # Gets information about a user's flair options.
      # @!method get_flair(type, name)
      # @param type [Symbol] The type of flair [user, link]
      # @param name [String] The username or link name.
      def get_flair(type, name)
        params = {}
        if type == :user
          params[:name] = name
        elsif type == :link
          params[:link] = name
        end
        path = "/r/#{display_name}/api/flairselector"
        @client.request_data(path, :post, params)
      end

      # Creates a flair template.
      # @!method flair_template(type, text, css_class, editable, template_id)
      # @param type [Symbol] The template type [USER_FLAIR, LINK_FLAIR]
      # @param text [String] The flair text.
      # @param css_class [String] The flair's CSS class.
      # @param editable [Boolean] Whether or not the user can edit the flair
      #   text.
      def flair_template(type, text, css_class, editable, template_id)
        params = {}
        params[:api_type] = 'json'
        params[:css_class] = css_class
        params[:flair_template_id] = template_id
        params[:flair_type] = type
        params[:text] = text
        params[:text_editable] = editable
        path = "/r/#{display_name}/api/flairtemplate"
        @client.request_data(path, :post, params)
      end
      # @!endgroup
    end
  end
end
