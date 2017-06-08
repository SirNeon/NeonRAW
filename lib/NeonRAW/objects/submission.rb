require_relative 'thing'
require_relative 'comment'
require_relative 'morecomments'

# rubocop:disable Metrics/MethodLength

module NeonRAW
  module Objects
    # The submission object.
    # @!attribute [r] archived?
    #   @return [Boolean] Returns whether or not the submission is archived.
    # @!attribute [r] author
    #   @return [String] Returns the author of the submission.
    # @!attribute [r] author_flair_css_class
    #   @return [String, nil] Returns the CSS class of the submitter's flair or
    #     nil if there is none.
    # @!attribute [r] author_flair_text
    #   @return [String, nil] Returns the flair's text of the submitter's flair
    #     or nil if there is none.
    # @!attribute [r] clicked?
    #   @return [Boolean] Returns whether or not the submission has been
    #     "clicked".
    # @!attribute [r] domain
    #   @return [String] Returns the domain of the submitted item.
    # @!attribute [r] hidden?
    #   @return [Boolean] Returns whether or not you hid the submission.
    # @!attribute [r] selfpost?
    #   @return [Boolean] Returns whether or not the submission is a selfpost.
    # @!attribute [r] link_flair_css_class
    #   @return [String, nil] Returns the CSS class for the submission's link
    #     flair or nil if there is none.
    # @!attribute [r] link_flair_text
    #   @return [String, nil] Returns the Link flair's text or nil if there is
    #     none.
    # @!attribute [r] locked?
    #   @return [Boolean] Returns whether or not the submission is locked.
    # @!attribute [r] media
    #   @return [Hash, nil] Returns an object containing information about a
    #     video and its origins or nil if there is none.
    # @!attribute [r] media_embed
    #   @return [Hash, nil] Returns an object containing technical embed
    #     information or nil if there is none.
    # @!attribute [r] num_comments
    #   @return [Integer] Returns the number of comments in the submission.
    # @!attribute [r] nsfw?
    #   @return [Boolean] Returns whether or not the post is flagged as NSFW.
    # @!attribute [r] permalink
    #   @return [String] Returns the permalink of the submission.
    # @!attribute [r] saved?
    #   @return [Boolean] Returns whether or not you saved the submission.
    # @!attribute [r] score
    #   @return [Integer] Returns the submission's karma score.
    # @!attribute [r] selftext
    #   @return [String, nil] Returns the text of selfposts or nil if there is
    #     none.
    # @!attribute [r] selftext_html
    #   @return [String, nil] Returns the text of selfposts with HTML or nil if
    #     there is none.
    # @!attribute [r] subreddit
    #   @return [String] Returns the subreddit the submission was posted to.
    # @!attribute [r] subreddit_id
    #   @return [String] Returns the ID of the subreddit where the submission
    #     was posted to.
    # @!attribute [r] thumbnail
    #   @return [String, nil] Returns the URL to the thumbnail of the post or
    #     nil if there is none.
    # @!attribute [r] title
    #   @return [String] Returns the title of the submission.
    # @!attribute [r] url
    #   @return [String] Either the URL submitted (link post) or the
    #     submission's permalink (selfpost).
    class Submission < Thing
      include Thing::Createable
      include Thing::Editable
      include Thing::Gildable
      include Thing::Moderateable
      include Thing::Refreshable
      include Thing::Repliable
      include Thing::Saveable
      include Thing::Votable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client
      #   object.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          # for consistency, empty strings/arrays/hashes are set to nil
          # because most of the keys returned by Reddit are nil when they
          # don't have a value, besides a few
          value = nil if ['', [], {}].include?(value)
          if key == :permalink
            instance_variable_set(:"@#{key}", 'https://www.reddit.com' + value)
          else
            instance_variable_set(:"@#{key}", value)
          end
          next if %i[created created_utc].include?(key)
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :clicked?, :clicked
          alias_method :hidden?, :hidden
          alias_method :selfpost?, :is_self
          alias_method :locked?, :locked
          alias_method :nsfw?, :over_18
          alias_method :saved?, :saved
          alias_method :archived?, :archived
          alias_method :add_comment, :reply
        end
      end

      # Checks whether or not the submission is a link post.
      # @!method linkpost?
      # @return [Boolean] Returns whether or not the submission is a link post.
      def linkpost?
        !@is_self
      end

      # Checks whether or not the submission has flair.
      # @!method flair?
      # @return [Boolean] Returns whether or not the submission has flair.
      def flair?
        !@link_flair_text.nil? || !@link_flair_css_class.nil?
      end

      # Checks whether or not this is a submission.
      # @!method submission?
      # @return [Boolean] Returns true.
      def submission?
        true
      end

      # Checks whether or not this is a comment.
      # @!method comment?
      # @return [Boolean] Returns false.
      def comment?
        false
      end

      # Fetches the comments for a submission.
      # @!method comments
      # @return [Array] Returns an array full of Comments and MoreComments
      #   objects.
      def comments
        data = @client.request_data("/comments/#{id}", :get)
        data_arr = []
        data[1][:data][:children].each do |comment|
          if comment[:kind] == 't1'
            data_arr << Comment.new(@client, comment[:data])
          elsif comment[:kind] == 'more'
            data_arr << MoreComments.new(@client, comment[:data])
          end
        end
        data_arr
      end

      # Set submission visibility.
      # @!method hide
      # @!method unhide
      # @note See lock/unlock for source code.

      # Set whether or not users can comment on the submission.
      # @!method lock
      # @!method unlock
      %w[hide unhide lock unlock].each do |type|
        define_method :"#{type}" do
          params = { id: name }
          @client.request_data("/api/#{type}", :post, params)
        end
      end

      # Set the submission's NSFW status.'
      # @!method mark_nsfw
      # @!method unmark_nsfw
      %w[mark unmark].each do |type|
        define_method :"#{type}_nsfw" do
          params = { id: name }
          @client.request_data("/api/#{type}nsfw", :post, params)
        end
      end

      # Toggle getting inbox replies from the submission.
      # @!method inbox_replies(enable)
      # @param enable [Boolean] Turns it on or off.
      def inbox_replies(enable)
        params = { id: name, state: enable }
        @client.request_data('/api/sendreplies', :post, params)
      end

      # Set contest mode on or off.
      # @!method contest_mode(enable)
      # @param enable [Boolean] Turns it on or off.
      def contest_mode(enable)
        params = { api_type: 'json', id: name, state: enable }
        @client.request_data('/api/set_contest_mode', :post, params)
      end

      # Sets the suggested sort for a submission.
      # @!method suggested_sort(sort)
      # @param sort [Symbol] The sort to set [confidence, top, new,
      #   controversial, old, random, qa]
      def suggested_sort(sort)
        params = { api_type: 'json', id: name, sort: sort }
        @client.request_data('/api/set_suggested_sort', :post, params)
      end

      # Sticky a submission/comment.
      # @!method sticky(enable)
      # @param enable [Boolean] Stickies/unstickies the thing.
      def sticky(enable)
        params = { api_type: 'json', id: name, state: enable }
        @client.request_data('/api/set_subreddit_sticky', :post, params)
      end

      # The submission's shortlink.
      # @!method shortlink
      # @return [String] Returns the submission's shortlink.
      def shortlink
        "https://redd.it/#{id}"
      end
    end
  end
end
