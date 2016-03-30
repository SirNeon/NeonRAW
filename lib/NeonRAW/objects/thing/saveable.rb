module NeonRAW
  module Objects
    class Thing
      # Methods for things that can be saved.
      module Saveable
        # Saves the thing.
        # @!method save(opts = {})
        # @param opts [Hash] Stores optional parameters.
        # @option opts :category [String] The category you want to save to.
        #   @note Only works if you have Reddit gold.
        def save(opts = {})
          params[:category] = opts[:category] if opts[:category]
          params[:id] = name
          @client.request_data('/api/save', :post, params)
        end

        # Unsaves the thing.
        # @!method unsave
        def unsave
          params[:id] = name
          @client.request_data('/api/unsave', :post, params)
        end
      end
    end
  end
end
