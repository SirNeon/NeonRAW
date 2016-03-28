require_relative '../../objects/submission'
require_relative '../../objects/listing'

module NeonRAW
  # Methods for building listings.
  module Listings
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    def build_listing(multiplier, _last_block_limit, path, params)
      data_arr = []
      multiplier.times do
        data = request_data(path, 'get', params)
        params[:after] = data[:data][:after]
        params[:before] = data[:data][:before]
        data[:data][:children].each do |submission|
          data_arr << Objects::Submission.new(submission)
        end
        break if params[:after].nil?
      end
      Objects::Listing.new(params[:after], params[:before]) + data_arr
    end

    %w(hot top old new controversial random).each do |type|
      define_method :"get_#{type}" do |subreddit, params = { limit: 25 }|
        path = "/r/#{subreddit}/#{type}/.json"
        if params[:limit] > 100
          multiplier = params[:limit] / 100
          last_block = (params[:limit] - (multiplier * 100)) - 1
          params[:limit] = 100
          params[:after] = '' if params[:after].nil?
          return build_listing(multiplier, last_block, path,
                               params)
        end
        params[:limit] -= 1
        build_listing(1, 0, path, params)
      end
    end
  end
end
