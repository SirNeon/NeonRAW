require_relative '../../objects/subreddit'
require_relative '../../objects/user'
require_relative '../../objects/me'
require_relative '../../objects/multireddit'

module NeonRAW
  module Clients
    class Base
      # Methods for building objects.
      module ObjectBuilder
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

        # Fetches a multireddit.
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

        # Creates a multireddit.
        # @!method create_multireddit(data, multireddit_path)
        # @param data [JSON] The multireddit data.
        # @param multireddit_path [String] The path to the multireddit (e.g.
        #   /user/username/m/multireddit_name)
        # @return [NeonRAW::Objects::MultiReddit] Returns the multireddit
        #   object.
        # @see https://www.reddit.com/dev/api#POST_api_multi_{multipath}
        def create_multireddit(data, multireddit_path)
          params = {}
          params[:model] = data
          params[:multipath] = multireddit_path
          params[:expand_srs] = false
          data = request_data("/api/multi/#{multireddit_path}", :post, params)
          Objects::MultiReddit.new(self, data[:data])
        end
      end
    end
  end
end
