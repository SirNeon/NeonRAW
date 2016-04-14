require_relative 'thing'

module NeonRAW
  module Objects
    # le multireddit object
    # @!attribute [r] editable?
    #   @return [Boolean] Returns whether or not you can edit the multireddit.
    # @!attribute [r] display_name
    #   @return [String] Returns the display name of the multireddit.
    # @!attribute [r] name
    #   @return [String] Returns the name of the multireddit.
    # @!attribute [r] description_html
    #   @return [String, nil] Returns the description of the multireddit with
    #     HTML or nil if there is none.
    # @!attribute [r] copied_from
    #   @return [String, nil] Returns where the multireddit was copied from or
    #     nil if it wasn't copied.
    # @!attribute [r] icon_url
    #   @return [String, nil] Returns the icon URL of the multireddit or nil if
    #     there is none.
    # @!attribute [r] key_color
    #   @return [String, nil] Returns the color of the key or nil if there is
    #     none.
    # @!attribute [r] visibility
    #   @return [String] Returns the visibility status of the multireddit
    #     [public, private, hidden].
    # @!attribute [r] icon_name
    #   @return [String, nil] Returns the name of the icon or nil if there is
    #     none ['art and design', 'ask', 'books', 'business', 'cars',
    #     'comics', 'cute animals', 'diy', 'entertainment', 'food and drink',
    #     'funny', 'games', 'grooming', 'health', 'life advice', 'military',
    #     'models pinup', 'music', 'news', 'philosophy', 'pictures and gifs',
    #     'science', 'shopping', 'sports', 'style', 'tech', 'travel',
    #     'unusual stories', 'video', '', 'None'].
    # @!attribute [r] weighting_scheme
    #   @return [String] Returns the weighting scheme for the multireddit
    #     [classic, fresh].
    # @!attribute [r] path
    #   @return [String] Returns the path to the multireddit.
    # @!attribute [r] description
    #   @return [String, nil] Returns the description of the multireddit or nil
    #     if there is none.
    class MultiReddit < Thing
      include Thing::Createable

      def initialize(client, data)
        @client = client
        data.each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
          next if key == :created || key == :created_utc || key == :subreddits
          self.class.send(:attr_reader, key)
        end
        class << self
          alias_method :editable?, :can_edit
          alias_method :description, :description_md
        end
      end

      # Fetches a list of subreddits in the multireddit.
      # @!method subreddits
      # @return [Array<String>] Returns a list of subreddit display_names.
      def subreddits
        subreddits = @subreddits || []
        subreddits.map { |subreddit| subreddit[:name] }
      end

      # Copy the multireddit.
      # @!method copy(opts = {})
      # @param opts [Hash] Optional parameters.
      # @option opts :name [String] The new name of the multireddit. Defaults to
      #   the name of the original copy.
      # @return [NeonRAW::Objects::MultiReddit] Returns the new object.
      def copy(opts = {})
        params = { display_name: display_name, from: path,
                   to: "/user/#{@client.me.name}/m/" }
        params[:to] += opts[:name] || display_name
        data = @client.request_data('/api/multi/copy', :post, params)
        MultiReddit.new(@client, data[:data])
      end

      # Renames the multireddit.
      # @!method rename!(new_name)
      # @param new_name [String] The new name for the multireddit.
      # @return [NeonRAW::objects::MultiReddit] Returns the multireddit object.
      def rename!(new_name)
        params = { display_name: new_name, from: path,
                   to: "/user/#{@client.me.name}/m/#{new_name}" }
        data = @client.request_data('/api/multi/rename', :post, params)
        MultiReddit.new(@client, data[:data])
      end

      # Deletes the multireddit.
      # @!method delete!
      def delete!
        @client.request_nonjson("/api/multi/#{path}", :delete)
      end

      # Edit the multireddit.
      # @!method edit(data)
      # @param data [JSON] The data for the multireddit.
      # @see https://www.reddit.com/dev/api#PUT_api_multi_{multipath}
      def edit(data)
        params = { model: data, multipath: path, expand_srs: false }
        data = @client.request_data("/api/multi/#{path}", :put, params)
        data[:data].each do |key, value|
          value = nil if ['', [], {}].include?(value)
          instance_variable_set(:"@#{key}", value)
        end
      end

      # Adds a subreddit to the multireddit.
      # @!method add_subreddit(subreddit)
      # @param subreddit [String] The name of the subreddit to add.
      def add_subreddit(subreddit)
        params = { model: { 'name' => subreddit }.to_json, multipath: path,
                   srname: subreddit }
        api_path = "/api/multi/#{path}/r/#{subreddit}"
        @client.request_data(api_path, :put, params)
        @subreddits << { name: subreddit }
      end

      # Remove a subreddit from the multireddit.
      # @!method remove_subreddit(subreddit)
      # @param subreddit [String] The name of the subreddit to remove.
      def remove_subreddit(subreddit)
        params = { multipath: path, srname: subreddit }
        api_path = "/api/multi/#{path}/r/#{subreddit}"
        @client.request_nonjson(api_path, :delete, params)
        @subreddits.delete(name: subreddit)
      end
    end
  end
end
