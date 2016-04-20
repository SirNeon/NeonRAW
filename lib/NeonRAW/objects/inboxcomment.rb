require_relative 'thing'

module NeonRAW
  module Objects
    # The inboxed comment object.
    # @!attribute [r] body
    #   @return [String, nil] Returns the text body of the comment or nil if
    #     there is none.
    # @!attribute [r] link_title
    #   @return [String] Returns the title of the submission where the comment
    #     was posted.
    # @!attribute [r] dest
    #   @return [String] Returns whom the InboxComment was sent to.
    # @!attribute [r] author
    #   @return [String] Returns the author of the comment.
    # @!attribute [r] body_html
    #   @return [String, nil] Returns the text body of the comment with HTML or
    #     nil if there is none.
    # @!attribute [r] subreddit
    #   @return [String] Returns the subreddit where the comment was posted.
    # @!attribute [r] parent_id
    #   @return [String] Returns the fullname of the comment's parent object.
    # @!attribute [r] context
    #   @return [String] Returns a link to the comment with context provided.
    # @!attribute [r] new?
    #   @return [Boolean] Returns whether the comment is new or not.
    # @!attribute [r] subject
    #   @return [String] Returns the subject of the comment (post/comment
    #     reply).
    class InboxComment < Thing
      include Thing::Createable
      include Thing::Inboxable
      include Thing::Moderateable
      include Thing::Repliable
      include Thing::Votable

      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
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
          alias_method :new?, :new
        end
      end
    end
  end
end
