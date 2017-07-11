module NeonRAW
  module Objects
    class Thing
      # Methods for things that can be replied to.
      module Repliable
        # Leaves a comment/PM reply to the thing.
        # @!method reply(text)
        # @param text [String] The text body of the comment.
        # @return [NeonRAW::Objects::Comment/PrivateMessage] Returns the object.
        def reply(text)
          params = { api_type: 'json', text: text, thing_id: name }
          data = @client.request_data('/api/comment', :post, params)
          object_data = data[:json][:data][:things][0][:data]
          kind = data[:json][:data][:things][0][:kind]
          if kind == 't1'
            Comment.new(@client, object_data)
          elsif kind == 't4'
            PrivateMessage.new(@client, object_data)
          end
        end
      end
    end
  end
end
