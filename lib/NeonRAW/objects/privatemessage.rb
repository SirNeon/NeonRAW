require_relative 'thing'

module NeonRAW
  module Objects
    # le PrivateMessage object
    # @!attribute [r] author
    #   @return [String] Returns the author of the private message.
    # @!attribute [r] body
    #   @return [String, nil] Returns the PM text body or nil if there is none.
    # @!attribute [r] was_comment?
    #   @return [Boolean] Returns whether or not the object was a comment first.
    # @!attribute [r] first_message
    #   @return [String, nil] Returns the first message ID or nil if there was
    #     none.
    # @!attribute [r] dest
    #   @return [String] Returns the user whom the PM was sent to.
    # @!attribute [r] body_html
    #   @return [String, nil] Returns the text body with HTML or nil if there
    #     is none.
    # @!attribute [r] subreddit
    #   @return [String, nil] Returns the subreddit it was sent from or nil if
    #     it wasn't a comment.
    # @!attribute [r] context
    #   @return [String, nil] Returns the comment permalink with context or nil
    #     if it wasn't a comment.
    # @!attribute [r] new?
    #   @return [Boolean] Returns whether or not the message is unread.
    # @!attribute [r] subject
    #   @return [String] Returns the subject of the PM.
    class PrivateMessage < Thing
      include Thing::Createable
      include Thing::Inboxable
      include Thing::Moderateable
      include Thing::Repliable

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc || key == :replies
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :was_comment?, :was_comment
        end
      end

      # Creates a list of replies to a private message.
      # @!method replies
      # @return [Array<NeonRAW::Objects::PrivateMessage>] Returns a list of
      #   replies.
      def replies
        return nil if @replies.nil?
        messages = []
        @replies[:data][:children].each do |reply|
          messages << PrivateMessage.new(@client, reply[:data])
        end
        messages
      end

      # Block a user.
      # @!method block!
      def block!
        params = { id: name }
        @client.request_data('/api/block', :post, params)
      end

      # Toggle the read status of a message.
      # @!method mark_as_read!
      # @!method mark_as_unread!
      %w(read unread).each do |type|
        define_method :"mark_as_#{type}!" do
          params = { id: name }
          @client.request_data("/api/#{type}_message", :post, params)
        end
      end

      # Set whether to mute a user in modmail or not.
      # @!method mute!
      # @!method unmute!
      %w(mute unmute).each do |type|
        define_method :"#{type}!" do
          params = { id: name }
          @client.request_data("/api/#{type}_message_author", :post, params)
        end
      end
    end
  end
end
