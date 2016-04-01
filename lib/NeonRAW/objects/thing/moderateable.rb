module NeonRAW
  module Objects
    class Thing
      # Methods for moderators.
      module Moderateable
        # Checks whether or not the thing was distinguished by a privileged
        # user.
        # @!method distinguished?
        # @return [Boolean] Returns whether or not the comment was
        #   distinguished.
        def distinguished?
          if @distinguished.nil?
            false
          else
            true
          end
        end

        # Distinguish a submission/comment.
        # @!method distinguish(type)
        # @param type [Symbol] The type of distinguish you want to do.
        # @option type :yes [Symbol] Distinguish the thing.
        # @option type :no [Symbol] Undistinguish the thing.
        # @option type :admin [Symbol] Admin Distinguish the thing (Admins
        #   only).
        # @option type :special [Symbol] Add a user-specific distinguish
        #   (Depends on the user).
        # @!group Moderators
        def distinguish(type)
          params = {}
          params[:api_type] = 'json'
          params[:how] = type
          params[:id] = name
          @client.request_data('/api/distinguish', :post, params)
          refresh!
        end

        # Checks who distinguished the thing.
        # @!method distinguished_by
        # @return [String, nil] Returns who distinguished the comment or nil if
        #   the comment isn't distinguished [moderator, admin, special].
        def distinguished_by
          @distinguished
        end

        # Checks whether or not the thing is stickied.
        # @!method stickied?
        # @return [Boolean] Returns whether or not the thing is stickied.
        def stickied?
          @stickied
        end
      end
    end
  end
end
