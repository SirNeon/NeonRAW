# rubocop:disable Style/AccessorMethodName, Metrics/LineLength
# rubocop:disable Metrics/MethodLength

module NeonRAW
  module Objects
    class Subreddit
      # Methods for flairs.
      module Flair
        # @!group Flair
        # Clears flair templates.
        # @!method clear_flair_templates(flair_type)
        # @param flair_type [Symbol] The type of flair [USER_FLAIR, LINK_FLAIR].
        def clear_flair_templates(flair_type)
          params = {}
          params[:api_type] = 'json'
          params[:flair_type] = flair_type
          path = "/r/#{display_name}/api/clearflairtemplates"
          @client.request_data(path, :post, params)
        end

        # Deletes a user's flair.
        # @!method delete_flair(username)
        # @param [String] The username of the user's whose flair will be deleted.
        def delete_flair(username)
          params = {}
          params[:api_type] = 'json'
          params[:name] = username
          path = "/r/#{display_name}/api/deleteflair"
          @client.request_data(path, :post, params)
        end

        # Delete a flair template.
        # @!method delete_flair_template(template_id)
        # @param template_id [String] The template's ID.
        def delete_flair_template(template_id)
          params = {}
          params[:api_type] = 'json'
          params[:flair_template_id] = template_id
          path = "/r/#{display_name}/api/deleteflairtemplate"
          @client.request_data(path, :post, params)
        end

        # Sets the flair on either a link or a user.
        # @!method set_flair(type, thing_name, text, css_class)
        # @param type [Symbol] The type of flair to set [user, link]
        # @param thing_name [String] Either the username or name of the link.
        # @param text [String] The flair text (64 characters max).
        # @param css_class [String] The CSS class of the flair.
        def set_flair(type, thing_name, text, css_class)
          params = {}
          params[:api_type] = 'json'
          params[:text] = text
          params[:css_class] = css_class
          if type == :user
            params[:name] = thing_name
          elsif type == :link
            params[:link] = thing_name
          end
          path = "/r/#{display_name}/api/flair"
          @client.request_data(path, :post, params)
        end

        # Configure the subreddit's flairs.
        # @!method flair_config(enabled, position, self_assign_enabled, link_flair_position, self_link_flair_assign)
        # @param enabled [Boolean] Enable/disable flair.
        # @param position [Symbol] Flair position [left, right].
        # @param self_assign_enabled [Boolean] Allow/disallow users to set their
        #   own flair.
        # @param link_flair_position [Symbol] Link flair position ['', left,
        #   right].
        # @param self_link_flair_assign [Boolean] Allow/disallow users to set
        #   their own link flair.
        def flair_config(enabled, position, self_assign_enabled,
                         link_flair_position, self_link_flair_assign)
          params = {}
          params[:api_type] = 'json'
          params[:flair_enabled] = enabled
          params[:flair_position] = position
          params[:flair_self_assign_enabled] = self_assign_enabled
          params[:link_flair_position] = link_flair_position
          params[:link_flair_self_assign_enabled] = self_link_flair_assign
          path = "/r/#{display_name}/api/flairconfig"
          @client.request_data(path, :post, params)
        end

        # Sets flairs for multiple users.
        # @!method set_many_flairs(flair_data)
        # @param flair_data [String] The flair data in CSV format. Format as such:
        #   User,flair text,CSS class.
        # @note This API can take up to 100 lines before it starts ignoring
        #   things. If the flair text and CSS class are both empty strings then
        #   it will clear the user's flair.
        # @todo Figure out how to properly format multiple CSV values.
        def set_many_flairs(flair_data)
          params = {}
          params[:flair_csv] = flair_data
          path = "/r/#{display_name}/api/flaircsv"
          @client.request_data(path, :post, params)
        end

        # Fetches a list of flairs.
        # @!method flairlist(params = { limit: 25 })
        # @param params [Hash] The parameters.
        # @option params :after [String] The name of the next data block.
        # @option params :before [String] The name of the previous data block.
        # @option params :count [Integer] The number of items already in the list.
        # @option params :limit [1..1000] The number of items to fetch.
        # @option params :name [String] The username of the user whose flair you
        #   want.
        # @option params :show [String] Literally the string 'all'.
        # @return [Hash<Array<Hash>>] Returns a list of the flairs.
        def flairlist(params = { limit: 25 })
          path = "/r/#{display_name}/api/flairlist"
          @client.request_data(path, :get, params)
        end

        # Gets information about a user's flair options.
        # @!method get_flair(type, name)
        # @param type [Symbol] The type of flair [user, link]
        # @param name [String] The username or link name.
        def get_flair(type, name)
          params = {}
          if type == :user
            params[:name] = name
          elsif type == :link
            params[:link] = name
          end
          path = "/r/#{display_name}/api/flairselector"
          @client.request_data(path, :post, params)
        end

        # Creates a flair template.
        # @!method flair_template(type, text, css_class, editable, template_id)
        # @param type [Symbol] The template type [USER_FLAIR, LINK_FLAIR]
        # @param text [String] The flair text.
        # @param css_class [String] The flair's CSS class.
        # @param editable [Boolean] Whether or not the user can edit the flair
        #   text.
        # @param template_id [String] The template's ID.
        def flair_template(type, text, css_class, editable, template_id)
          params = {}
          params[:api_type] = 'json'
          params[:css_class] = css_class
          params[:flair_template_id] = template_id
          params[:flair_type] = type
          params[:text] = text
          params[:text_editable] = editable
          path = "/r/#{display_name}/api/flairtemplate"
          @client.request_data(path, :post, params)
        end
        # @!endgroup
      end
    end
  end
end
