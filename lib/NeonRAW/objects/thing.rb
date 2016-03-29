require_relative 'thing/votable'

module NeonRAW
  module Objects
    # Exists to hold methods that work in all objects.
    class Thing
      class << self
        public :define_method
      end
      include Votable
    end
  end
end
