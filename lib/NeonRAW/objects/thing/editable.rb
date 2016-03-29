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
  end
end
