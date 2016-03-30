module NeonRAW
  module Objects
    class Thing
      # Methods for objects that you can cast votes on.
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
            upvote: [1, true],
            clear_vote: [0, nil],
            downvote: [-1, false]
          }
        end

        # Cast a vote on an object.
        # @!method upvote
        # @!method clear_vote
        # @!method downvote
        # @return [Hash] Returns a hash containing the parsed JSON data.
        %i(upvote clear_vote downvote).each do |type|
          define_method type do
            params = {}
            params[:dir] = votes[type][0]
            params[:id] = name
            @client.request_data('/api/vote', :post, params)
            update_vote_value(votes[type][1])
          end
        end

        # Updates the vote value of an object after casting a vote on it.
        # @!method update_vote_value(value)
        # @param value [Boolean, nil] The value to update with.
        def update_vote_value(value)
          @likes = value
        end

        private :votes, :update_vote_value
      end
    end
  end
end
