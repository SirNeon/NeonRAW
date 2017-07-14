module NeonRAW
  module Objects
    class Thing
      # Methods for editing.
      module Editable
        # Checks whether or not the thing was edited.
        # @!method edited?
        # @return [Boolean] Returns whether or not the comment was edited.
        def edited?
          if @edited != false
            true
          else
            false
          end
        end

        # Gets the timestamp of the thing's lastest edit.
        # @!method last_edit
        # @return [Time, nil] Returns the Time of the edit or nil if
        #   the comment hasn't been edited.
        # @note If you crawl some old comments on /r/reddit.com this may return
        #   true instead of the timestamp.
        def last_edit
          if @edited == true
            @edited
          elsif @edited.is_a?(Float)
            Time.at(@edited)
          end
        end

        # Edit a thing.
        # @!method edit!(text)
        # @param text [String] The text to replace the current text with.
        def edit!(text)
          params = { api_type: 'json', text: text, thing_id: name }
          @client.request_data('/api/editusertext', :post, params)
          refresh!
        end

        # Deletes the thing.
        # @!method delete!
        def delete!
          params = { id: name }
          @client.request_data('/api/del', :post, params)
          refresh!
        end
      end
    end
  end
end
