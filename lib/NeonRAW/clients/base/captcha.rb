module NeonRAW
  class Base
    # Methods for captchas.
    module Captchas
      # Checks whether captchas are needed for API methods that define the
      # captcha and iden parameters.
      # @!method needs_captcha?
      # @return [String] Returns "true" or "false".
      def needs_captcha?
        request_nonjson('/api/needs_captcha', :get)
      end

      # Fetches a captcha link for you.
      # @!method new_captcha
      # @return [String] Returns a link to the captcha image.
      def new_captcha
        params = {}
        params[:api_type] = 'json'
        data = request_data('/api/new_captcha', :post, params)
        iden = data[:json][:data][:iden]
        "https://www.reddit.com/captcha/#{iden}.png"
      end
    end
  end
end
