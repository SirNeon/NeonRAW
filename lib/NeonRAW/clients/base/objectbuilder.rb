require_relative '../../objects/subreddit'
require_relative '../../objects/user'
require_relative '../../objects/me'
require_relative '../../objects/multireddit'
require_relative '../../objects/wikipage'
require_relative '../../objects/all'
require_relative '../../objects/popular'

module NeonRAW
  module Clients
    class Base
      # Methods for building objects.
      module ObjectBuilder
        SUBREDDIT_DEFAULTS = {
          'allow_top' => true,
          'collapse_deleted_comments' => false,
          'comment_score_hide_mins' => 0,
          'exclude_banned_modqueue' => false,
          'header-title' => '',
          'hide_ads' => false,
          'lang' => 'en',
          'link_type' => 'any',
          'over_18' => false,
          'public_traffic' => false,
          'show_media' => true,
          'spam_comments' => 'low',
          'spam_links' => 'high',
          'spam_selfposts' => 'high',
          'submit_text_label' => 'Submit a new text post',
          'submit_text' => '',
          'submit_link_label' => 'Submit a new link',
          'suggested_comment_sort' => 'confidence',
          'type' => 'public',
          'wiki_edit_age' => 0,
          'wiki_edit_karma' => 100,
          'wikimode' => 'disabled'
        }.freeze

        # Fetches a subreddit.
        # @!method subreddit(name)
        # @param name [String] The name of the subreddit.
        # @return [NeonRAW::Objects::Subreddit/All/Popular] Returns the
        #   subreddit/all/popular object.
        def subreddit(name)
          if name == 'all'
            Objects::All.new(self)
          elsif name == 'popular'
            Objects::Popular.new(self)
          else
            data = request_data("/r/#{name}/about.json", :get)[:data]
            Objects::Subreddit.new(self, data)
          end
        end

        # Fetches a user.
        # @!method user(name)
        # @param name [String] The name of the user.
        # @return [NeonRAW::Objects::User] Returns the user object.
        def user(name)
          data = request_data("/user/#{name}/about.json", :get)[:data]
          Objects::User.new(self, data)
        end

        # Fetches yourself.
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
        # @!method create_subreddit(name, title, description, opts = {})
        # @param name [String] The name of the subreddit.
        # @param title [String] The title of the subreddit (100
        #   characters maximum).
        # @param description [String] The sidebar text for the subreddit.
        # @param opts [Hash] Optional parameters.
        # @option opts allow_top [Boolean] Whether or not the subreddit can be
        #   displayed on /r/all.
        # @option opts collapse_deleted_comments [Boolean] Whether or not to
        #   collapse deleted comments.
        # @option opts comment_score_hide_mins [0..1440] The number of minutes
        #   to hide comment scores.
        # @option opts exclude_banned_modqueue [Boolean] Whether or not to
        #   exclude sitewide banned users from modqueue.
        # @option opts header-title [String] The title for the subreddit (500
        #   characters maximum).
        # @option opts hide_ads [Boolean] Whether or not to hide ads in the
        #   subreddit.
        # @option opts lang [String] The IETF language tags of the subreddit
        #   separated by underscores.
        # @option opts link_type [String] The type of submissions allowed [any,
        #   link, self].
        # @option opts over_18 [Boolean] Whether or not the subreddit is NSFW.
        # @option opts public_description [String] The message that will get
        #   shown to people when the subreddit is private.
        # @option opts public_traffic [Boolean] Whether or not the subreddit's
        #   traffic stats are publicly available.
        # @option opts show_media [Boolean] Whether or not to show media.
        # @option opts spam_comments [String] Set the spamfilter [low, high,
        #   all].
        # @option opts spam_links [String] Set the spamfilter [low, high, all].
        # @option opts spam_selfposts [String] Set the spamfilter [low, high,
        #   all].
        # @option opts submit_text_label [String] The label for the selfpost
        #   button (60 characters maximum).
        # @option opts submit_text [String] The text to display when making a
        #   selfpost.
        # @option opts submit_link_label [String] The label for the link button
        #   (60 characters maximum).
        # @option opts suggested_comment_sort [String] The suggested comment
        #   sort for the subreddit [confidence, top, new, controversial, old,
        #   random, qa].
        # @option opts type [String] The subreddit type [gold_restricted,
        #   archived, restricted, gold_only, employees_only, private, public].
        # @option opts wiki_edit_age [Integer] The minimum account age needed to
        #   edit the wiki.
        # @option opts wiki_edit_karma [Integer] The minimum karma needed to
        #   edit the wiki.
        # @option opts wikimode [String] The mode of the subreddit's wiki
        #   [disabled, modonly, anyone].
        # @return [NeonRAW::Objects::Subreddit] Returns the subreddit object.
        def create_subreddit(name, title, description, opts = {})
          params = SUBREDDIT_DEFAULTS.dup
          params.merge! opts
          params['api_type'] = 'json'
          params['name'] = name
          params['title'] = title
          params['description'] = description
          request_data('/api/site_admin', :post, params)
          subreddit(name)
        end

        # Fetches a wiki page.
        # @!method wikipage(page)
        # @param page [String] The name of the page.
        # @return [NeonRAW::Objects::WikiPage] Returns the wiki page object.
        def wikipage(page)
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
