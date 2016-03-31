require_relative 'thing'
require_relative 'comment'
require_relative 'morecomments'
# rubocop:disable Metrics/MethodLength, Metrics/AbcSize

module NeonRAW
  module Objects
    # le submission object
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
      include Thing::Saveable
      include Thing::Votable

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
          alias_method :clicked?, :clicked
          alias_method :hidden?, :hidden
          alias_method :selfpost?, :is_self
          alias_method :locked?, :locked
          alias_method :nsfw?, :over_18
          alias_method :saved?, :saved
        end
      end

      # Fetches the comments for a submission.
      # @!method comments
      # @return [Array] Returns an array full of Comments and MoreComments
      #   objects.
      def comments
        data = @client.request_data(permalink + '.json', :get)
        data_arr = []
        data[1][:data][:children].each do |comment|
          if comment[:kind] == 't1'
            data_arr << Objects::Comment.new(@client, comment[:data])
          elsif comment[:kind] == 'more'
            data_arr << Objects::MoreComments.new(@client, comment[:data])
          end
        end
        data_arr
      end

      # Flattens comment trees into a single array.
      # @!method flatten_comments(comments)
      # @param comments [Array] A list of comments to be checked for replies to
      #   flatten.
      # @return [Array] Returns a list of the flattened comments.
      def flatten_comments(comments)
        flattened = []
        stack = comments.dup

        until stack.empty?
          comment = stack.shift
          if comment.is_a?(Comment)
            replies = comment.replies
            stack = replies + stack unless replies.nil?
          end
          flattened << comment
        end
        flattened
      end

      # Adds a comment to the submission.
      # @!method add_comment(text)
      # @param text [String] The text for the comment body.
      # @return [Hash] Returns a hash containing the parsed JSON.
      def add_comment(text)
        params = {}
        params[:api_type] = 'json'
        params[:text] = text
        params[:thing_id] = name
        @client.request_data('/api/comment', :post, params)
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
