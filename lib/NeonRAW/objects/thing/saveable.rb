module NeonRAW
  module Objects
    class Thing
      # Methods for things that can be saved.
      module Saveable
        # Saves the thing.
        # @!method save(opts = {})
        # @param opts [Hash] Stores optional parameters.
        # @option opts :category [String] The category you want to save to
        #   (Reddit Gold Feature).
        def save(opts = {})
          params = { id: name }
          params[:category] = opts[:category] if opts[:category]
          @client.request_data('/api/save', :post, params)
        end

        # Unsaves the thing.
        # @!method unsave
        def unsave
          params = { id: name }
          @client.request_data('/api/unsave', :post, params)
        end
      end
    end
  end
end
