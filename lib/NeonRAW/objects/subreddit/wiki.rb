require_relative '../thing'
require_relative '../wikipage'

module NeonRAW
  module Objects
    class Subreddit < Thing
      # Methods for wiki pages.
      module WikiPages
        # Fetches the wiki page.
        # @!method wikipage(page)
        # @param page [String] The name of the page.
        # @return [NeonRAW::Objects::WikiPage] Returns the wiki page object.
        def wikipage(page)
          params = { page: page }
          path = "/r/#{display_name}/wiki/#{page}"
          data = @client.request_data(path, :get, params)
          data[:data][:name] = page
          data[:data][:subreddit] = display_name
          WikiPage.new(@client, data[:data])
        end

        # Fetches a list of wiki pages for the subreddit.
        # @!method wikipages
        # @return [Array<String>] Returns a list of wiki pages.
        def wikipages
          @client.request_data("/r/#{display_name}/wiki/pages", :get)[:data]
        end
      end
    end
  end
end
