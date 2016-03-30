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
