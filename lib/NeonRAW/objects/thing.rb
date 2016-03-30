require_relative 'thing/votable'
require_relative 'thing/editable'
require_relative 'thing/moderateable'
require_relative 'thing/gildable'
require_relative 'thing/createable'

module NeonRAW
  module Objects
    # Exists to hold methods that work in all objects.
    class Thing
      class << self
        public :define_method
      end
      include Createable
      include Editable
      include Gildable
      include Moderateable
      include Votable
    end
  end
end
