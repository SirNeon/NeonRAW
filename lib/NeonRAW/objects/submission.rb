require_relative 'thing'
# rubocop:disable Metrics/MethodLength

module NeonRAW
  module Objects
    # le submission object
    # @!attribute [r] author
    #   @return [String] Returns the submitter of the submission.
    # @!attribute [r] author_flair_css_class
    #   @return [String, nil] Returns the CSS class of the submitter's flair or
    #     nil if there is none.
    # @!attribute [r] author_flair_text
    #   @return [String, nil] Returns the flair's text of the submitter's flair
    #     or nil if there is none.
    # @!attribute [r] clicked?
    #   @return [Boolean] Returns whether or not the submission has been
    #     "clicked".
    # @!attribute [r] domain
    #   @return [String] Returns the domain of the submitted item.
    # @!attribute [r] hidden?
    #   @return [Boolean] Returns whether or not you hid the submission.
    # @!attribute [r] selfpost?
    #   @return [Boolean] Returns whether or not the submission is a selfpost.
    # @!attribute
    class Submission < Thing
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
        class << self
          alias_method :clicked?, :clicked
          alias_method :hidden?, :hidden
          alias_method :selfpost?, :is_self
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
