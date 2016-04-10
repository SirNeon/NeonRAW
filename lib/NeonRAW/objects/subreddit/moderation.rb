require_relative '../thing'

module NeonRAW
  module Objects
    class Subreddit < Thing
      # Methods for moderators.
      module Moderation
        # @!group Listing
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

        # Fetches the subreddit's modmail.
        # @!method get_modmail(params = { limit: 25 })
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
        def get_modmail(params = { limit: 25 })
          path = "/r/#{display_name}/about/message/inbox"
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

        # Fetches users with altered privileges.
        # @!method get_banned(params = { limit: 25 })
        # @!method get_muted(params = { limit: 25 })
        # @!method get_wikibanned(params = { limit: 25 })
        # @!method get_contributors(params = { limit: 25 })
        # @!method get_wikicontributors(params = { limit: 25 })
        # @!method get_moderators(params = { limit: 25 })
        # @param params [Hash] The parameters.
        # @option params :after [String] Fullname of the next data block.
        # @option params :before [String] Fullname of the previous data block.
        # @option params :count [Integer] Number of items already in the
        #   listing.
        # @option params :limit [1..1000] The number of listing items to fetch.
        # @option params :show [String] Literally the string 'all'.
        # @option params :user [String] The name of the user to fetch.
        # @return [Array<Hash>] Returns the data of the users.
        %w(banned muted wikibanned
           contributors wikicontributors moderators).each do |type|
             define_method :"get_#{type}" do |params = { limit: 25 }|
               data_arr = []
               path = "/r/#{display_name}/about/#{type}"
               until data_arr.length == params[:limit]
                 data = @client.request_data(path, :get, params)
                 params[:after] = data[:data][:after]
                 params[:before] = data[:data][:before]
                 data[:data][:children].each do |item|
                   data_arr << item
                   break if data_arr.length == params[:limit]
                 end
                 break if params[:after].nil?
               end
               data_arr
             end
           end
        # @!endgroup

        # Accept a pending mod invite to the subreddit.
        # @!method accept_mod_invite!
        def accept_mod_invite!
          params = {}
          params[:api_type] = 'json'
          path = "/r/#{display_name}/api/accept_moderator_invite"
          @client.request_data(path, :post, params)
          refresh!
        end

        # Ditch your privileged status in the subreddit.
        # @!method leave_contributor!
        # @!method leave_moderator!
        %w(contributor moderator).each do |type|
          define_method :"leave_#{type}!" do
            params = {}
            params[:id] = name
            @client.request_data("/api/leave#{type}", :post, params)
            refresh!
          end
        end

        # Upload a subreddit image.
        # @!method upload_image!(file_name, file_type, image_name, upload_type)
        # @param file_path [String] The path to the file (500 KiB maximum).
        # @param file_type [String] The file extension [png, jpg].
        # @param image_name [String] The name of the image.
        # @param upload_type [String] The type of upload [img, header, icon,
        #   banner].
        def upload_image!(file_path, file_type, image_name, upload_type)
          params = {}
          params[:img_type] = file_type
          params[:name] = image_name
          params[:upload_type] = upload_type
          path = "/r/#{display_name}/api/upload_sr_img"
          @client.request_upload(path, file_path, params)
          refresh!
        end

        # Remove a subreddit image.
        # @!method remove_banner!
        # @!method remove_header!
        # @!method remove_icon!
        %w(banner header icon).each do |type|
          define_method :"remove_#{type}!" do
            params = {}
            params[:api_type] = 'json'
            path = "/r/#{display_name}/api/delete_sr_#{type}"
            @client.request_data(path, :post, params)
            refresh!
          end
        end

        # Remove a subreddit image.
        # @!method remove_image!(image)
        # @param image [String] The name of the image.
        def remove_image!(image)
          params = {}
          params[:api_type] = 'json'
          params[:img_name] = image
          path = "/r/#{display_name}/api/delete_sr_img"
          @client.request_data(path, :post, params)
          refresh!
        end

        # Edit the subreddit's stylesheet.
        # @!method edit_stylesheet(data, opts = {})
        # @param data [String] The CSS for the stylesheet.
        # @param opts [Hash] Optional parameters.
        # @option opts :reason [String] The reason for the edit (256 characters
        #   maximum).
        def edit_stylesheet(data, opts = {})
          params = {}
          params[:api_type] = 'json'
          params[:op] = 'save'
          params[:reason] = opts[:reason]
          params[:stylesheet_contents] = data
          path = "/r/#{display_name}/api/subreddit_stylesheet"
          @client.request_data(path, :post, params)
        end
      end
    end
  end
end
