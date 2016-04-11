require_relative 'thing'

module NeonRAW
  module Objects
    # le wikipage object
    # @!attribute [r] revisable?
    #   @return [Boolean] Returns whether or not you can revise the wiki page.
    # @!attribute [r] content_html
    #   @return [String, nil] Returns the content of the wiki page with HTML or
    #     nil if there is none.
    # @!attribute [r] content
    #   @return [String, nil] Returns the content of the wiki page or nil if
    #     there is none.
    class WikiPage
      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :revision_date || key == :revision_by
          self.class.send(:attr_reader, key)
        end

        class << self
          alias_method :revisable?, :may_revise
          alias_method :content, :content_md
        end
      end

      # The user who made the last revision to the wiki page.
      # @!method revised_by
      # @return [String] Returns the username of the user.
      def revised_by
        @revision_by[:data][:name]
      end

      # The date of the last revision to the wiki page.
      # @!method revision_date
      # @return [Time] Returns the date.
      def revision_date
        Time.at(@revision_date)
      end
    end
  end
end
