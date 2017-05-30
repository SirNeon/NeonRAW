module NeonRAW
  module Objects
    class Thing
      # Methods for objects that you can cast votes on.
      # @!attribute [r] ups
      #   @return [Integer] Returns the number of upvotes the thing has.
      # @!attribute [r] downs
      #   @return [Integer] Returns the number of downvotes the thing has.
      module Votable
        # Checks whether you voted on the thing.
        # @!method voted?
        # @return [Boolean] Returns whether or not you voted on the thing.
        def voted?
          if @likes.nil?
            false
          else
            true
          end
        end

        # Checks whether or not you upvoted the thing.
        # @!method upvoted?
        # @return [Boolean] Returns whether or not you upvoted the thing.
        def upvoted?
          if @likes == true
            true
          else
            false
          end
        end

        # Checks whether or not you downvoted the thing.
        # @!method downvoted?
        # @return [Boolean] Returns whether or not you downvoted the thing.
        def downvoted?
          if @likes == false
            true
          else
            false
          end
        end

        # Contains the values for each type of vote.
        # @!method votes
        # @return [Hash] Returns a hash containing the vote values.
        def votes
          {
            upvote: 1,
            clear_vote: 0,
            downvote: -1
          }
        end

        # Cast a vote on an object.
        # @!method upvote
        # @!method clear_vote
        # @!method downvote
        %i[upvote clear_vote downvote].each do |type|
          define_method type do
            params = { dir: votes[type], id: name }
            @client.request_data('/api/vote', :post, params)
            refresh!
          end
        end
        private :votes
      end
    end
  end
end
