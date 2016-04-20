require_relative 'thing'

module NeonRAW
  module Objects
    # The comment object.
    # @!attribute [r] approved_by
    #   @return [String, nil] Returns which mod approved the comment or nil if
    #     none did or you aren't a moderator of that subreddit.
    # @!attribute [r] archived?
    #   @return [Boolean] Returns whether or not the comment is archived.
    # @!attribute [r] author
    #   @return [String] Returns the author of the comment.
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
    #     nil if there isn't one.
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
    class Comment < Thing
      include Thing::Createable
      include Thing::Editable
      include Thing::Gildable
      include Thing::Inboxable
      include Thing::Moderateable
      include Thing::Refreshable
      include Thing::Repliable
      include Thing::Saveable
      include Thing::Votable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client
      #   object.
      # @param data [Hash] The comment data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc || key == :replies
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :removed_by, :banned_by
          alias_method :gold_count, :gilded
          alias_method :saved?, :saved
          alias_method :score_hidden?, :score_hidden
          alias_method :archived?, :archived
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
      # @return [Array<NeonRAW::Objects::Comment,
      #   NeonRAW::Objects::MoreComments>, nil] Returns either a list of the
      #   Comments/MoreComments or nil if there were no replies.
      def replies
        return nil if @replies.nil?
        comments = []
        @replies[:data][:children].each do |reply|
          if reply[:kind] == 't1'
            comments << Comment.new(@client, reply[:data])
          elsif reply[:kind] == 'more'
            comments << MoreComments.new(@client, reply[:data])
          end
        end
        comments
      end
    end
  end
end
