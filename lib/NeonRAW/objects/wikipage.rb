require_relative 'wikipagerevision'
require_relative 'listing'

module NeonRAW
  module Objects
    # le wikipage object
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
            data_arr << WikiPageRevision.new(@client, item)
            break if data_arr.length == params[:limit]
          end
          break if params[:after].nil?
        end
        listing = Objects::Listing.new(params[:after], params[:before])
        data_arr.each { |revision| listing << revision }
        listing
      end

      # Change the wiki contributors.
      # @!method add_editor(username)
      # @!method remove_editor(username)
      # @param username [String] The username of the user.
      %w(add remove).each do |type|
        self.class.send(:define_method, :"#{type}_editor") do |username|
          params = {}
          type = 'del' if type == 'remove'
          params[:act] = type
          params[:page] = name
          params[:username] = username
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
        params = {}
        params[:reason] = opts[:reason]
        params[:content] = text
        params[:page] = name
        path = "/r/#{subreddit}/api/wiki/edit"
        @client.request_data(path, :post, params)
        data = @client.request_data("/r/#{subreddit}/wiki/#{name}", :get)
        data[:data].each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
        end
      end
    end
  end
end
