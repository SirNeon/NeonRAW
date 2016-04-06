require_relative '../../objects/listing'
require_relative '../../objects/subreddit'
require_relative '../../objects/comment'
require_relative '../../objects/access'
require_relative '../../objects/privatemessage'
require_relative '../../objects/modlogaction'
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
        private :build_listing
      end
    end
  end
end
