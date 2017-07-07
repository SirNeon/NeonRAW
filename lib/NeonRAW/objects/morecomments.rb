require_relative 'comment'

module NeonRAW
  module Objects
    # The MoreComments object.
    class MoreComments
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          # for consistency, empty strings/arrays/hashes are set to nil
          # because most of the keys returned by Reddit are nil when they
          # don't have a value, besides a few
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end

      # Returns whether or not the object is a MoreComments object.
      # @!method morecomments?
      # @return [Boolean] Returns true.
      def morecomments?
        true
      end

      # Returns whether or not the object is a Comment object.
      # @!method comment?
      # @return [Boolean] Returns false.
      def comment?
        false
      end

      # Expands the MoreComments object.
      # @!method expand
      # @return [NeonRAW::Objects::Listing] Returns a listing with all of the
      #   comments that were expanded.
      def expand
        return [] if children.nil?
        # /api/morechildren is buggy shit. This is better.
        @client.info(name: children.map { |the_id| 't1_' + the_id }.join(','))
      end
    end
  end
end
