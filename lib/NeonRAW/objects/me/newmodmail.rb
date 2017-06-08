module NeonRAW
  module Objects
    class Me < User
      # Methods for new modmail.
      module NewModmail
        # Marks new modmail as read.
        # @!method mark_modmail_as_read(subreddits, category)
        # @param subreddits [Array<String>] The list of subreddits to mark as
        #   read.
        # @param category [Symbol] The category to mark as read [new,
        #   inprogress, mod, notifications, archived, highlighted, all]
        def mark_modmail_as_read(subreddits, category)
          params = { entity: subreddits.join(','), state: category }
          @client.request_data('/api/mod/bulk_read', :post, params)
        end
      end
    end
  end
end
