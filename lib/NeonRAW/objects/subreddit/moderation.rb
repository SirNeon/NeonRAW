require_relative '../thing'

module NeonRAW
  module Objects
    class Subreddit < Thing
      # Methods for moderators.
      module Moderation
        # Fetches the modlog for the subreddit.
        # @!method get_modlog(params = { limit: 25 })
        # @param params [Hash] The parameters.
        # @option params :after [String] Fullname of the next data block.
        # @option params :before [String] Fullname of the previous data block.
        # @option params :count [Integer] The number of items already in the
        #   listing.
        # @option params :limit [1..500] The number of listing items to fetch.
        # @option params :mod [String] The moderator to filter actions by. Also
        #   'a' can be given to filter by admin actions.
        # @option params :show [String] Literally the string 'all'.
        # @option params :type [String] The type of mod action to filter by
        #   [banuser, unbanuser, removelink, approvelink, removecomment,
        #   approvecomment, addmoderator, invitemoderator, uninvitemoderator,
        #   acceptmoderatorinvite, removemoderator, addcontributor,
        #   removecontributor, editsettings, editflair, distinguish, marknsfw,
        #   wikibanned, wikicontributor, wikiunbanned, wikipagelisted,
        #   removewikicontributor, wikirevise, wikipermlevel, ignorereports,
        #   unignorereports, setpermissions, setsuggestedsort, sticky, unsticky,
        #   setcontestmode, unsetcontestmode, lock, unlock, muteuser,
        #   unmuteuser, createrule, editrule, deleterule]
        # @return [NeonRAW::Objects::Listing] Returns a listing of the modlog
        #   actions.
        def get_modlog(params = { limit: 25 })
          path = "/r/#{display_name}/about/log.json"
          @client.send(:build_listing, path, params)
        end

        # Fetches things for review by moderators.
        # @!method get_reported(params = { limit: 25 })
        # @!method get_spam(params = { limit: 25 })
        # @!method get_modqueue(params = { limit: 25 })
        # @!method get_unmoderated(params = { limit: 25 })
        # @!method get_edited(params = { limit: 25 })
        # @param params [Hash] The parameters.
        # @option params :after [String] Fullname of the next data block.
        # @option params :before [String] Fullname of the previous data block.
        # @option params :count [Integer] The number of things already in the
        #   listing.
        # @option params :limit [1..1000] The number of listing items to fetch.
        # @option params :only [Symbol] Only fetch either [links, comments].
        # @option params :show [String] Literally the string 'all'.
        # @return [NeonRAW::Objects::Listing] Returns a listing with all the
        #   things.
        %w(reported spam modqueue unmoderated edited).each do |type|
          define_method :"get_#{type}" do |params = { limit: 25 }|
            type = 'reports' if type == 'reported'
            path = "/r/#{display_name}/about/#{type}.json"
            @client.send(:build_listing, path, params)
          end
        end

        # Accept a pending mod invite to the subreddit.
        # @!method accept_mod_invite!
        def accept_mod_invite!
          params = {}
          params[:api_type] = 'json'
          path = "/r/#{display_name}/api/accept_moderator_invite"
          @client.request_data(path, :post, params)
        end

        # Ditch your privileged status in the subreddit.
        # @!method leave_contributor!
        # @!method leave_moderator!
        %w(contributor moderator).each do |type|
          define_method :"leave_#{type}!" do
            params = {}
            params[:id] = name
            @client.request_data("/api/leave#{type}", :post, params)
          end
        end
      end
    end
  end
end
