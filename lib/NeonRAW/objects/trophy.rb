require_relative 'thing'

module NeonRAW
  module Objects
    # le Trophy object
    # @!attribute [r] icon_70
    #   @return [String] Returns a link to the icon file.
    # @!attribute [r] description
    #   @return [String, nil] Returns the description or nil if there is none.
    # @!attribute [r] url
    #   @return [String, nil] Returns the URL or nil if there is none.
    # @!attribute [r] icon_40
    #   @return [String] Returns a link to the icon file.
    # @!attribute [r] award_id
    #   @return [String] Returns the award ID.
    class Trophy < Thing
      def initialize(data)
        data.each do |key, value|
          instance_variable_set(:"@#{key}", value)
          self.class.send(:attr_reader, key)
        end
      end
    end
  end
end
