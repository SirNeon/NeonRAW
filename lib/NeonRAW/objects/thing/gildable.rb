module NeonRAW
  # Methods for things that can be gilded.
  module Gildable
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
  end
end
