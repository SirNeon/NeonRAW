module NeonRAW
  module Objects
    # le revision object
    # @!attribute [r] reason
    #   @return [String, nil] Returns the reason for the revision.
    # @!attribute [r] page
    #   @return [String] Returns the name of the wiki page.
    # @!attribute [r] id
    #   @return [String] Returns the ID of the revision.
    class WikiPageRevision
      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :timestamp || key == :author
          self.class.send(:attr_reader, key)
        end
      end

      # @!attribute [r] author
      #   @return [String] Returns the user who made the revision.
      def author
        @author[:data][:name]
      end

      # The time and date when the revision was created.
      # @!method created
      # @return [Time] Returns when the revision was made.
      def created
        Time.at(@timestamp)
      end

      # The time and date when the revision was created in UTC.
      # @!method created_utc
      # @return [Time] Returns when the revision was made in UTC.
      def created_utc
        Time.at(@timestamp).utc
      end
    end
  end
end
