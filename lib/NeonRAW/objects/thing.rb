require_relative 'thing/votable'

module NeonRAW
  module Objects
    # Exists to hold methods that work in all objects.
    class Thing
      include Votable
    end
  end
end
