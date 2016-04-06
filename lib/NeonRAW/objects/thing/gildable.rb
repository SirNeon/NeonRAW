module NeonRAW
  module Objects
    class Thing
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
        # @!method gild(quantity)
        # @param quantity [Integer] The amount of gold to give.
        def gild(quantity)
          quantity.times do
            @client.request_data("/api/v1/gold/gild/#{name}", :post)
          end
          refresh!
        end
      end
    end
  end
end
