require_relative 'wikipagerevision'
require_relative 'listing'

module NeonRAW
  module Objects
    # The wikipage object.
    # @!attribute [r] revisable?
    #   @return [Boolean] Returns whether or not you can revise the wiki page.
    # @!attribute [r] content_html
    #   @return [String, nil] Returns the content of the wiki page with HTML or
    #     nil if there is none.
    # @!attribute [r] content
    #   @return [String, nil] Returns the content of the wiki page or nil if
    #     there is none.
    # @!attribute [r] name
    #   @return [String] Returns the name of the wiki page.
    # @!attribute [r] subreddit
    #   @return [String] Returns the subreddit of the wiki page.
    class WikiPage
      class << self
        public :define_method
      end

      # @!method initialize(client, data)
      # @param client [NeonRAW::Clients::Web/Installed/Script] The client.
      # @param data [Hash] The object data.
      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :revision_date || key == :revision_by
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :revisable?, :may_revise
          alias_method :content, :content_md
        end
      end

      # The user who made the last revision to the wiki page.
      # @!method revised_by
      # @return [String] Returns the username of the user.
      def revised_by
        @revision_by[:data][:name]
      end

      # The date of the last revision to the wiki page.
      # @!method revision_date
      # @return [Time] Returns the date.
      def revision_date
        Time.at(@revision_date)
      end

      # @!group Listings
      # Gets the revisions made to the wiki page.
      # @!method revisions(params = { limit: 25 })
      # @param params [Hash] The parameters.
      # @option params :after [String] Fullname of the next data block.
      # @option params :before [String] Fullname of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns the list of revisions.
      def revisions(params = { limit: 25 })
        data_arr = []
        path = "/r/#{subreddit}/wiki/revisions/#{name}"
        until data_arr.length == params[:limit]
          data = @client.request_data(path, :get, params)
          params[:after] = data[:data][:after]
          params[:before] = data[:data][:before]
          data[:data][:children].each do |item|
            item[:subreddit] = subreddit
            data_arr << WikiPageRevision.new(@client, item)
            break if data_arr.length == params[:limit]
          end
          break if params[:after].nil?
        end
        listing = Objects::Listing.new(params[:after], params[:before])
        data_arr.each { |revision| listing << revision }
        listing
      end

      # Fetches submissions about the wiki page.
      # @!method discussions(params = { limit: 25 })
      # @param params [Hash] The parameters.
      # @option params :after [String] Fullname of the next data block.
      # @option params :before [String] Fullname of the previous data block.
      # @option params :count [Integer] The number of items already in the
      #   listing.
      # @option params :limit [1..1000] The number of listing items to fetch.
      # @option params :show [String] Literally the string 'all'.
      # @return [NeonRAW::Objects::Listing] Returns a listing with all the
      #   submissions.
      def discussions(params = { limit: 25 })
        params[:page] = name
        path = "/r/#{subreddit}/wiki/discussions/#{name}"
        @client.send(:build_listing, path, params)
      end
      # @!endgroup

      # Change the wiki contributors.
      # @!method add_editor(username)
      # @!method remove_editor(username)
      # @param username [String] The username of the user.
      %w(add remove).each do |type|
        define_method :"#{type}_editor" do |username|
          params = { page: name, username: username }
          type = 'del' if type == 'remove'
          params[:act] = type
          path = "/r/#{subreddit}/api/wiki/alloweditor/#{type}"
          @client.request_data(path, :post, params)
        end
      end

      # Edit the wiki page.
      # @!method edit!(text, opts = {})
      # @param text [String] The content for the page.
      # @param opts [Hash] Optional parameters.
      # @option opts :reason [String] The reason for the edit (256 characters
      #   maximum).
      def edit!(text, opts = {})
        params = { reason: opts[:reason], content: text, page: name }
        path = "/r/#{subreddit}/api/wiki/edit"
        @client.request_data(path, :post, params)
        data = @client.request_data("/r/#{subreddit}/wiki/#{name}", :get)
        data[:data].each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
        end
      end

      # Reverts the wiki page to this revision.
      # @!method revert!(revision)
      # @param revision [NeonRAW::Objects::WikiPageRevision] The revision you
      #   want to revert back to.
      def revert!(revision)
        params = { page: name, revision: revision.id }
        path = "/r/#{subreddit}/api/wiki/revert"
        @client.request_data(path, :post, params)
        path = "/r/#{subreddit}/wiki/#{name}"
        data = @client.request_data(path, :get, page: name)
        data[:data].each do |key, value|
          instance_variable_set(:"@#{key}", value)
        end
      end

      # Fetches the settings for the wiki.
      # @!method settings
      # @return [Hash<Integer, Array<String>, Boolean>] Returns the wiki
      #   page's settings.
      def settings
        path = "/r/#{subreddit}/wiki/settings/#{name}"
        @client.request_data(path, :get, page: name)[:data]
      end

      # Edits the settings of the wiki.
      # @!method edit_settings(data)
      # @param data [Hash] The parameters.
      # @option data :listed [Boolean] Whether or not the wiki page will be
      #   listed on the list of wiki pages.
      # @option data :permlevel [String] Set the permission level needed to
      #   edit the wiki [use_subreddit_settings, approved_only, mods_only].
      def edit_settings(data)
        permlevel = { 'use_subreddit_settings' => 0, 'approved_only' => 1,
                      'mods_only' => 2 }
        params = { page: name, permlevel: permlevel[data[:permlevel]],
                   listed: data[:listed] }
        params[:page] = name
        path = "/r/#{subreddit}/wiki/settings/#{name}"
        @client.request_data(path, :post, params)[:data]
      end
    end
  end
end
