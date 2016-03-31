require_relative 'thing/votable'
require_relative 'thing/editable'
require_relative 'thing/moderateable'
require_relative 'thing/gildable'
require_relative 'thing/createable'
require_relative 'thing/saveable'
require_relative 'thing/refreshable'
require_relative 'thing/inboxable'

module NeonRAW
  module Objects
    # Exists to hold methods that work in all objects.
    # @!attribute [r] id
    #   @return [String] The id of the thing.
    # @!attribute [r] name
    #   @return [String] The fullname of the thing.
    class Thing
      class << self
        public :define_method
      end
    end
  end
end
