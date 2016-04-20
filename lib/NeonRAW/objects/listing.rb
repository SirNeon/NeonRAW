module NeonRAW
  module Objects
    # The listing object.
    class Listing < Array
      attr_reader :after, :before
      def initialize(after, before)
        @after = after
        @before = before
      end
    end
  end
end
