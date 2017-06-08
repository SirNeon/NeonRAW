module NeonRAW
  module Objects
    # The object for /r/popular.
    class Popular
      # @!method initialize(client)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client
      #   object.
      def initialize(client)
        @client = client
      end

      # @!group Listings
      # Fetches a listing from /r/popular.
      # @!method hot(params = { limit: 25 })
      # @!method rising(params = { limit: 25 })
      # @!method top(params = { limit: 25 })
      # @!method old(params = { limit: 25 })
      # @!method new(params = { limit: 25 })
      # @!method controversial(params = { limit: 25 })
      # @!method comments(param = { limit: 25 })
      # @param params [Hash] The parameters for the request.
      # @option params :t [String] Time for relevant sorting [hour, day, week,
      #   month, year, all]
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns the listing object.
      %w[hot rising top old new controversial comments].each do |type|
        define_method :"#{type}" do |params = { limit: 25 }|
          path = "/r/popular/#{type}"
          @client.send(:build_listing, path, params)
        end
      end

      # Streams content from /r/popular.
      # @!method stream(queue, params = { limit: 25 })
      # @param queue [String] The queue to get data from [hot, top, new,
      #   controversial, gilded, comments]
      # @param params [Hash] The parameters for the request.
      # @option params :t [String] Time for relevant sorting [hour, day, week,
      #   month, year, all]
      # @option params :after [String] The name of the next data block.
      # @option params :before [String] The name of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [Enumerator] Returns an enumerator for the streamed data.
      def stream(queue, params = { limit: 25 })
        @client.send(:stream, "/r/popular/#{queue}", params)
      end
    end
  end
end
