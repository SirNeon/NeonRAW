module NeonRAW
  # Methods for things that can be created.
  module Createable
    def created
      Time.at(@created)
    end

    def created_utc
      Time.at(@created_utc)
    end
  end
end
