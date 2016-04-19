require_relative '../../objects/subreddit'
require_relative '../../objects/user'
require_relative '../../objects/me'
require_relative '../../objects/multireddit'
require_relative '../../objects/wikipage'

module NeonRAW
  module Clients
    class Base
      # Methods for building objects.
      module ObjectBuilder
        # Creates a subreddit object.
        # @!method subreddit(name)
        # @param name [String] The name of the subreddit.
        # @return [NeonRAW::Objects::Subreddit] Returns the subreddit object.
        def subreddit(name)
          data = request_data("/r/#{name}/about.json", :get)[:data]
          Objects::Subreddit.new(self, data)
        end

        # Creates a user object.
        # @!method user(name)
        # @param name [String] The name of the user.
        # @return [NeonRAW::Objects::User] Returns the user object.
        def user(name)
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
        # @!method multireddit(multireddit_path)
        # @param multireddit_path [String] The path to the multireddit (e.g.
        #   /user/username/m/multireddit_name).
        # @return [NeonRAW::Objects::MultiReddit] Returns the multireddit
        #   object.
        def multireddit(multireddit_path)
          params = { multipath: multireddit_path, expand_srs: false }
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
          params = { model: data, multipath: multireddit_path,
                     expand_srs: false }
          data = request_data("/api/multi/#{multireddit_path}", :post, params)
          Objects::MultiReddit.new(self, data[:data])
        end

        # Creates a subreddit.
        # @!method create_subreddit(name, data)
        # @param name [String] The name of the subreddit.
        # @param data [Hash] The data of the subreddit.
        # @option data allow_top [Boolean] Whether or not the subreddit can be
        #   displayed on /r/all.
        # @option data collapse_deleted_comments [Boolean] Whether or not to
        #   collapse deleted comments.
        # @option data comment_score_hide_mins [0..1440] The number of minutes
        #   to hide comment scores.
        # @option data description [String] The sidebar text for the subreddit.
        # @option data exclude_banned_modqueue [Boolean] Whether or not to
        #   exclude sitewide banned users from modqueue.
        # @option data header-title [String] The title for the subreddit (500
        #   characters maximum).
        # @option data hide_ads [Boolean] Whether or not to hide ads in the
        #   subreddit.
        # @option data lang [String] The IETF language tags of the subreddit
        #   separated by underscores.
        # @option data link_type [String] The type of submissions allowed [any,
        #   link, self].
        # @option data over_18 [Boolean] Whether or not the subreddit is NSFW.
        # @option data public_description [String] The message that will get
        #   shown to people when the subreddit is private.
        # @option data public_traffic [Boolean] Whether or not the subreddit's
        #   traffic stats are publicly available.
        # @option data show_media [Boolean] Whether or not to show media.
        # @option data spam_comments [String] Set the spamfilter [low, high,
        #   all].
        # @option data spam_links [String] Set the spamfilter [low, high, all].
        # @option data spam_selfposts [String] Set the spamfilter [low, high,
        #   all].
        # @option data submit_text_label [String] The label for the selfpost
        #   button (60 characters maximum).
        # @option data submit_text [String] The text to display when making a
        #   selfpost.
        # @option data submit_link_label [String] The label for the link button
        #   (60 characters maximum).
        # @option data suggested_comment_sort [String] The suggested comment
        #   sort for the subreddit [confidence, top, new, controversial, old,
        #   random, qa].
        # @option data title [String] The title of the subreddit (100
        #   characters maximum).
        # @option data type [String] The subreddit type [gold_restricted,
        #   archived, restricted, gold_only, employees_only, private, public].
        # @option data wiki_edit_age [Integer] The minimum account age needed to
        #   edit the wiki.
        # @option data wiki_edit_karma [Integer] The minimum karma needed to
        #   edit the wiki.
        # @option data wikimode [String] The mode of the subreddit's wiki
        #   [disabled, modonly, anyone].
        # @return [NeonRAW::Objects::Subreddit] Returns the subreddit object.
        def create_subreddit(name, data)
          params = data
          params[:api_type] = 'json'
          params[:name] = name
          request_data('/api/site_admin', :post, params)
          subreddit(name)
        end

        # Fetches a wiki page.
        # @!method get_wikipage(page)
        # @param page [String] The name of the page.
        # @return [NeonRAW::Objects::WikiPage] Returns the wiki page object.
        def get_wikipage(page)
          params = { page: page }
          path = "/wiki/#{page}.json"
          data = request_data(path, :get, params)
          data[:data][:name] = page
          Objects::WikiPage.new(self, data[:data])
        end
      end
    end
  end
end
