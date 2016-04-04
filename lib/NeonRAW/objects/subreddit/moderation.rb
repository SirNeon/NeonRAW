module NeonRAW
  # Methods for moderators.
  module Moderation
    # Fetch the modlog for the subreddit.
    # @!method get_modlog(params = { limit: 25 })
    # @param params [Hash] The parameters.
    # @option params :after [String] Fullname of the next data block.
    # @option params :before [String] Fullname of the previous data block.
    # @option params :count [Integer] The number of items already in the
    #   listing.
    # @option params :limit [1..500] The number of listing items to fetch.
    # @option params :mod [String] The moderator to filter actions by. Also 'a'
    #   can be given to filter by admin actions.
    # @option params :show [String] Literally the string 'all'.
    # @option params :type [String] The type of mod action to filter by
    #   [banuser, unbanuser, removelink, approvelink, removecomment,
    #   approvecomment, addmoderator, invitemoderator, uninvitemoderator,
    #   acceptmoderatorinvite, removemoderator, addcontributor,
    #   removecontributor, editsettings, editflair, distinguish, marknsfw,
    #   wikibanned, wikicontributor, wikiunbanned, wikipagelisted,
    #   removewikicontributor, wikirevise, wikipermlevel, ignorereports,
    #   unignorereports, setpermissions, setsuggestedsort, sticky, unsticky,
    #   setcontestmode, unsetcontestmode, lock, unlock, muteuser, unmuteuser,
    #   createrule, editrule, deleterule]
    def get_modlog(params = { limit: 25 })
      @client.request_data("/r/#{display_name}/about/log.json", :get, params)
    end
  end
end
