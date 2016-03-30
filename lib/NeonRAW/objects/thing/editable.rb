module NeonRAW
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
    # @return [Float, nil] Returns the UNIX timestamp of the edit or nil if
    #   the comment hasn't been edited.
    # @note If you crawl some old comments on /r/reddit.com this may return
    #   true instead of the timestamp.
    def last_edit
      nil || @edited if @edited != false
    end

    # Edit a thing.
    # @!method edit(text)
    # @param text [String] The text to replace the current text with.
    def edit(text)
      params = {}
      params[:api_type] = 'json'
      params[:text] = text
      params[:thing_id] = name
      @client.request_data('/api/editusertext', :post, params)
    end

    # Updates the text body of the thing.
    # @!method update_text_body(kind, body, body_html)
    # @param kind [String] The type of object [t1, t3]
    # @param body [String] The new text to replace the old text.
    # @param body_html [String] The new text with HTML to replace the old text
    #   with HTML.
    def update_text_body(kind, body, body_html)
      if kind == 't1'
        @body = body
        @body_html = body_html
      elsif kind == 't3'
        @selftext = body
        @selftext_html = body_html
      end
    end
    private :update_text_body
  end
end
