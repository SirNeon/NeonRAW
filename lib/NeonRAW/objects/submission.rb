module NeonRAW
  module Objects
    # le submission object
    class Submission
      # @!method initialize(client, data)
      # @param client [NeonRAW::Web/Installed/Script] The client object.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end

      # Adds a comment to the submission.
      # @!method add_comment(text)
      # @param text [String] The text for the comment body.
      # @return [Hash] Returns a hash containing the parsed JSON.
      def add_comment(text)
        params = {}
        params[:api_type] = 'json'
        params[:text] = text
        params[:thing_id] = name
        @client.request_data('/api/comment', :post, params)
      end
    end
  end
end
