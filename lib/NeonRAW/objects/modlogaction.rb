require_relative 'thing'

module NeonRAW
  module Objects
    # The modlogaction object.
    # @!attribute [r] description
    #   @return [String, nil] Returns the description or nil if there is none.
    # @!attribute [r] target_body
    #   @return [String, nil] Returns the text body of the target object or nil
    #     if there is none.
    # @!attribute [r] mod_id36
    #   @return [String] Returns the ID of the mod who did the action.
    # @!attribute [r] subreddit
    #   @return [String] Returns the subreddit where the action occured.
    # @!attribute [r] target_title
    #   @return [String, nil] Returns the title of the target object or nil if
    #     there is none.
    # @!attribute [r] target_permalink
    #   @return [String, nil] Returns the permalink of the target object or nil
    #     if there is none.
    # @!attribute [r] details
    #   @return [String] Returns the details of the action.
    # @!attribute [r] action
    #   @return [String] Returns the type of action.
    # @!attribute [r] target_author
    #   @return [String, nil] Returns the author of the target object or nil if
    #     there is none.
    # @!attribute [r] target_fullname
    #   @return [String, nil] Returns the fullname of the target object or nil
    #     if there is none.
    # @!attribute [r] sr_id36
    #   @return [String] Returns the ID of the subreddit where the action
    #     occured.
    # @!attribute [r] mod
    #   @return [String] Returns the mod who did the action.
    # @!attribute [r] id
    #   @return [String] Returns the ID of the modlog action.
    class ModLogAction
      include Thing::Createable

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created_utc
          self.class.send(:attr_reader, key)
        end
      end

      # Gets when the mod log action was done.
      # @!method created
      # @return [Time] Returns the date/time when the mod log action was done.
      def created
        Time.at(@created_utc).localtime
      end
    end
  end
end
