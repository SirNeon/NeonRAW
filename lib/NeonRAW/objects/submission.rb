module NeonRAW
  module Objects
    # le submission object
    class Submission
      def initialize(data)
        data.each do |key, value|
          value = nil if value == ''
          self.class.send(:define_method, key) do
            instance_variable_set(:"@#{key}", value)
          end
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
        data = request_data('/api/comment', 'post', params)
        JSON.parse(data.body, symbolize_names: true)
      end
    end
  end
end
