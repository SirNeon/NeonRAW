require_relative 'thing'

module NeonRAW
  module Objects
    # le PrivateMessage object
    # @!attribute [r] body
    #   @return [String, nil] Returns the PM text body or nil if there is none.
    # @!attribute [r] was_comment?
    #   @return [Boolean] Returns whether or not the object was a comment first.
    # @!attribute [r] first_message
    #   @return [String, nil] Returns the first message ID or nil if there was
    #     none.
    # @!attribute [r] dest
    #   @return [String] Returns the user whom the PM was sent to.
    # @!attribute [r] author
    #   @return [String] Returns the sender of the PM.
    # @!attribute [r] body_html
    #   @return [String, nil] Returns the text body with HTML or nil if there
    #     is none.
    # @!attribute [r] subreddit
    #   @return [String, nil] Returns the subreddit it was sent from or nil if
    #     it wasn't a comment.
    # @!attribute [r] context
    #   @return [String, nil] Returns the comment permalink with context or nil
    #     if it wasn't a comment.
    # @!attribute [r] id
    #   @return [String] The ID of the private message.
    # @!attribute [r] new?
    #   @return [Boolean] Returns whether or not the message is unread.
    # @!attribute [r] subject
    #   @return [String] Returns the subject of the PM.
    class PrivateMessage < Thing
      include Thing::Createable
      include Thing::Inboxable
      include Thing::Moderateable

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :was_comment?, :was_comment
        end
      end
    end
  end
end
