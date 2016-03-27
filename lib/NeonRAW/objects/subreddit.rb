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
    #   @return [String] Returns a string container a link to the
    #     banner image.
    # @!attribute [r] submit_text_html
    #   @return [String] Returns the text with HTML included in the
    #     thread submission page.
    # @!attribute [r] id
    #   @return [String] Returns the id of the subreddit.
    # @!attribute [r] submit_text
    #   @return [String] Returns the text included in the thread
    #     submission page.
    # @!attribute [r] display_name
    #   @return [String] Returns the display name of the subreddit.
    # @!attribute [r] header_img
    #   @return [String] Returns the link to the header image.
    # @!attribute [r] description_html
    #   @return [String] Returns the subreddit description with HTML.
    # @!attribute [r] title
    #   @return [String] Returns the subreddit's title.
    # @!attribute [r] public_description
    #   @return [String] Returns the subreddit's public description.
    # @!attribute [r] public_description_html
    #   @return [String] Returns the subreddit's public description
    #     with HTML included.
    # @!attribute [r] suggested_comment_sort
    #   @return [String, nil] Returns the subreddit's suggested
    #     comment sort or nil if there isn't one.
    # @!attribute [r] header_title
    #   @return [String] Returns a string containing the header
    #     title.
    # @!attribute [r] description
    #   @return [String] Returns the subreddit's description.
    # @!attribute [r] accounts_active
    #   @return [Integer] Returns the number of users online browsing
    #     the subreddit.
    # @!attribute [r] header_size
    #   @return [Array] Returns an array containing the header's
    #     dimensions.
    # @!attribute [r] subscribers
    #   @return [Integer] Returns the number of subscribers the
    #     subreddit has.
    # @!attribute [r] lang
    #   @return [String] Returns the subreddit's primary language.
    # @!attribute [r] name
    #   @return [String] Returns the subreddit's name.
    # @!attribute [r] created
    #   @return [Float] Returns the time when the subreddit was
    #     created (UNIX timestamp).
    # @!attribute [r] created_utc
    #   @return [Float] Returns the time when the subreddit was
    #     created in UTC (UNIX timestamp).
    # @!attribute [r] url
    #   @return [String] Returns the subreddit's URL.
    # @!attribute [r] comment_score_hide_mins
    #   @return [Integer] Returns the number of minutes that comment
    #     scores are hidden.
    # @!attribute [r] subreddit_type
    #   @return [String] Returns the type of subreddit [public,
    #     restricted, private].
    # @!attribute [r] submission_type
    #   @return [String] Returns the type of submissions allowed
    #     to be posted [any, link, self].
    class Subreddit
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def initialize(data)
        data.each do |key, value|
          self.class.send(:define_method, key) do
            instance_variable_set(:"@#{key}", value)
          end
        end
        class << self
          alias_method :subscribed?, :user_is_subscriber
          alias_method :approved_submitter?, :user_is_contributor
          alias_method :moderator?, :user_is_moderator
          alias_method :im_banned?, :user_is_banned
          alias_method :collapse_deleted_comments?, :collapse_deleted_comments
          alias_method :nsfw?, :over18
          alias_method :muted?, :user_is_muted
          alias_method :quarantined?, :quarantine
          alias_method :public_traffic?, :public_traffic
          alias_method :theme_enabled?, :user_sr_theme_enabled
          alias_method :wiki_enabled?, :wiki_enabled
          alias_method :hide_ads?, :hide_ads
        end
      end
    end
  end
end
