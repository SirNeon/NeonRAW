module NeonRAW
  module Objects
    class Thing
      # Methods for things that can be created.
      module Createable
        # Fetch when the thing was created.
        # @!method created
        # @return [Time] Returns a Time object containing the time/date.
        def created
          Time.at(@created)
        end

        # Fetch when the thing was created UTC.
        # @!method created_utc
        # @return [Time] Returns a Time object containing the time/date.
        def created_utc
          Time.at(@created_utc)
        end
      end
    end
  end
end
