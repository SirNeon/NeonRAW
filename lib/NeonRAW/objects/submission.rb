module NeonRAW
  module Objects
    # le submission object
    class Submission
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end

      # Adds a comment to the submission.
      # @!method add_comment(text, params = {})
      # @param text [String] The text for the comment body.
      # @return [Hash] Returns a hash containing the parsed JSON.
      def add_comment(text)
        params = {}
        params[:api_type] = 'json'
        params[:thing_id] = name
        params[:text] = text
        @client.request_data('/api/comment', 'post', params)
      end
    end
  end
end
