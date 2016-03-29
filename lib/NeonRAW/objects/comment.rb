require_relative 'thing'
# rubocop:disable Metrics/MethodLength

module NeonRAW
  module Objects
    # le comment object
    # @!attribute [r] approved_by
    #   @return [String, nil] Returns which mod approved the comment or nil if
    #     none did or you aren't a moderator of that subreddit.
    # @!attribute [r] author
    #   @return [String] Returns who made the comment.
    # @!attribute [r] author_flair_css_class
    #   @return [String, nil] Returns the author's flair CSS class or nil if
    #     there is none.
    # @!attribute [r] author_flair_text
    #   @return [String, nil] Returns the author's flair text or nil if there
    #     is none.
    # @!attribute [r] removed_by
    #   @return [String, nil] Returns which mod removed the comment or nil if
    #     none did or you aren't a moderator of that subreddit.
    # @!attribute [r] body
    #   @return [String, nil] Returns the text body of the comment or nil if
    #     there isn't one.
    # @!attribute [r] body_html
    #   @return [String, nil] Returns the text body of the comment with HTML or
    #   nil if there isn't one.
    # @!attribute [r] gold_count
    #   @return [Integer] Returns the amount of gold a comment has been given.
    # @!attribute [r] link_author
    #   @return [String] Returns the author of the submission link that the
    #     comment was made in response to.
    #   @note This attribute only exists if the comment is fetched from outside
    #     the thread it was posted in (so like user pages,
    #     /r/subreddit/comments, that type of stuff).
    # @!attribute [r] link_id
    #   @return [String] Returns the id of the link that this comment is in.
    # @!attribute [r] link_title
    #   @return [String] Returns the title of the parent link.
    #   @note This attribute only exists if the comment is fetched from outside
    #     the thread it was posted in (so like user pages,
    #     /r/subreddit/comments, that type of stuff).
    # @!attribute [r] link_url
    #   @return [String] Returns the URL of the parent link.
    #   @note This attribute only exists if the comment is fetched from outside
    #     the thread it was posted in (so like user pages,
    #     /r/subreddit/comments, that type of stuff).
    # @!attribute [r] num_reports
    #   @return [Integer, nil] Returns the number of times the comment has been
    #     reported or nil if it hasn't or you aren't a moderator.
    # @!attribute [r] parent_id
    #   @return [String] Returns the ID of either the link or the comment that
    #     this comment is a reply to.
    # @!attribute [r] saved?
    #   @return [Boolean] Returns whether or not you saved the comment.
    # @!attribute [r] score
    #   @return [Integer] Returns the karma score of the comment.
    # @!attribute [r] score_hidden?
    #   @return [Boolean] Returns whether or not the karma score of the comment
    #     is hidden.
    # @!attribute [r] subreddit
    #   @return [String] Returns the subreddit the comment was posted to.
    # @!attribute [r] subreddit_id
    #   @return [String] Returns the ID of the subreddit where the comment was
    #     posted to.
    # @!attribute [r] distinguished_by
    #   @return [String, nil] Returns who distinguished the comment or nil if
    #     the comment isn't distinguished [moderator, admin, special].
    class Comment < Thing
      # @!method initialize(client, data)
      # @param client [NeonRAW::Web/Installed/Script] The client object.
      # @param data [Hash] The comment data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :removed_by, :banned_by
          alias_method :gold_count, :gilded
          alias_method :saved?, :saved
          alias_method :score_hidden?, :score_hidden
          alias_method :distinguished_by, :distinguished
        end
      end

      # Checks whether or not the comment was edited.
      # @!method edited?
      # @return [Boolean] Returns whether or not the comment was edited.
      def edited?
        if @edited != false
          true
        else
          false
        end
      end

      # Gets the timestamp of the comment's lastest edit.
      # @!method last_edit
      # @return [Float, nil] Returns the UNIX timestamp of the edit or nil if
      #   the comment hasn't been edited.
      # @note If you crawl some old comments on /r/reddit.com this may return
      #   true instead of the timestamp.
      def last_edit
        nil || @edited if @edited != false
      end

      # Checks whether a comment was gilded or not.
      # @!method gilded?
      # @return [Boolean] Returns whether or not the comment was gilded.
      def gilded?
        if @gilded > 0
          true
        else
          false
        end
      end

      # Checks whether or not the comment has replies to it.
      # @!method replies?
      # @return [Boolean] Returns whether or not the comment has replies to it.
      def replies?
        if @replies.nil?
          false
        else
          true
        end
      end

      # Gets the replies made to the comment.
      # @!method replies
      # @return [Array, nil] Returns either a list of the comments or nil if
      #   there were no replies.
      def replies
        return nil if @replies.nil?
        data_arr = []
        @replies[:data][:children].each do |reply|
          data_arr << Comment.new(@client, reply[:data])
        end
        data_arr
      end

      # Checks whether or not the comment was distinguished by a privileged
      # user.
      # @!method distinguished?
      # @return [Boolean] Returns whether or not the comment was distinguished.
      def distinguished?
        if @distinguished.nil?
          false
        else
          true
        end
      end

      # Replies to a comment.
      # @!method reply(text)
      # @param text [String] The text to reply with.
      # @return [Hash] The parsed JSON response.
      def reply(text)
        params = {}
        params[:api_type] = 'json'
        params[:text] = text
        params[:thing_id] = name
        @client.request_data('/api/comment', :post, params)
      end
    end
  end
end
