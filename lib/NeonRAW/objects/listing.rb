module NeonRAW
  module Objects
    # le listing object
    class Listing < Array
      attr_reader :after, :before
      def initialize
        @after = ''
        @before = ''
      end
    end
  end
end
