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

    # Give a thing gold.
    # @!method gild
    # @param quantity [Integer] The amount of gold to give.
    def gild(quantity)
      quantity.times do
        @client.request_data("/api/v1/gold/gild/#{name}", :post)
        update_gild_count(1)
      end
    end

    # Updates the gold count of a thing.
    # @!method update_gild_count(count)
    # @param count [1..36]
    def update_gild_count(count)
      @gilded += count
    end
    private :update_gild_count
  end
end
