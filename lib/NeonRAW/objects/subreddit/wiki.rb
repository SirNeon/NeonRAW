require_relative '../thing'
require_relative '../wikipage'

module NeonRAW
  module Objects
    class Subreddit < Thing
      # Methods for wiki pages.
      module WikiPages
        # Fetches the wiki page.
        # @!method get_wikipage(page)
        # @param page [String] The name of the page.
        def get_wikipage(page)
          params = { page: page }
          path = "/r/#{display_name}/wiki/#{page}"
          data = @client.request_data(path, :get, params)
          WikiPage.new(@client, data[:data])
        end
      end
    end
  end
end
