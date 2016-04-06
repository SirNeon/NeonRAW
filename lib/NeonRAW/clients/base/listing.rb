require_relative '../../objects/subreddit'
require_relative '../../objects/user'
require_relative '../../objects/me'
require_relative '../../objects/access'
require_relative '../../objects/privatemessage'
require_relative '../../objects/modlogaction'
require_relative '../../objects/multireddit'
require_relative '../../errors'
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

module NeonRAW
  module Clients
    class Base
      # Methods for building listings.
      module Listings
        OBJECT_KINDS = {
          'Listing' => Objects::Listing,
          'modaction' => Objects::ModLogAction,
          't1' => Objects::Comment,
          't3' => Objects::Submission,
          't4' => Objects::PrivateMessage
        }.freeze

        # Creates the listing object.
        # @!method build_listing(path, params)
        # @param path [String] The API path for the listing.
        # @param params [Hash] The parameters for the request.
        # @return [NeonRAW::Objects::Listing] Returns the Listing object.
        def build_listing(path, params)
          data_arr = []
          until data_arr.length == params[:limit]
            data = request_data(path, :get, params)
            params[:after] = data[:data][:after]
            params[:before] = data[:data][:before]
            data[:data][:children].each do |item|
              data_arr << OBJECT_KINDS[item[:kind]].new(self, item[:data])
              break if data_arr.length == params[:limit]
            end
            break if params[:after].nil?
          end
          listing = OBJECT_KINDS['Listing'].new(params[:after], params[:before])
          data_arr.each { |submission| listing << submission }
          listing
        end

        # Creates a subreddit object.
        # @!method get_subreddit(name)
        # @param name [String] The name of the subreddit.
        # @return [NeonRAW::Objects::Subreddit] Returns the subreddit object.
        def get_subreddit(name)
          data = request_data("/r/#{name}/about.json", :get)[:data]
          Objects::Subreddit.new(self, data)
        end

        # Creates a user object.
        # @!method get_user(name)
        # @param name [String] The name of the user.
        # @return [NeonRAW::Objects::User] Returns the user object.
        def get_user(name)
          data = request_data("/user/#{name}/about.json", :get)[:data]
          Objects::User.new(self, data)
        end

        # Creates a me object.
        # @!method me
        # @return [NeonRAW::Objects::Me] Returns the me object.
        def me
          data = request_data('/api/v1/me', :get)
          Objects::Me.new(self, data)
        end

        # Creates a multireddit object.
        # @!method get_multireddit(multireddit_path)
        # @param multireddit_path [String] The path to the multireddit (e.g.
        #   /user/username/m/multireddit_name).
        # @return [NeonRAW::Objects::MultiReddit] Returns the multireddit
        #   object.
        def get_multireddit(multireddit_path)
          params = {}
          params[:multipath] = multireddit_path
          params[:expand_srs] = false
          data = request_data("/api/multi/#{multireddit_path}", :get, params)
          Objects::MultiReddit.new(self, data[:data])
        end
        private :build_listing
      end
    end
  end
end
