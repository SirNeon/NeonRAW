module NeonRAW
  module Objects
    class Thing
      # Methods for things that appear in your inbox.
      module Inboxable
        # Changes the read status of a PM.
        # @!method mark_as_read
        # @!method mark_as_unread
        %w[read unread].each do |type|
          define_method :"mark_as_#{type}" do
            params = { id: name }
            @client.request_data("/api/#{type}_message", :post, params)
          end
        end

        # Add a text reply to a comment/private message.
        # @!method reply(text)
        # @param text [String] The text you want to reply with.
        def reply(text)
          params = { api_type: 'json', text: text, thing_id: name }
          @client.request_data('/api/comment', :post, params)
        end
      end
    end
  end
end
