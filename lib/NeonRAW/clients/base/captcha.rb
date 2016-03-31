module NeonRAW
  class Base
    # Methods for captchas.
    module Captchas
      def needs_captcha?
        request_data('/api/needs_captcha', :get)
      end

      def new_captcha
        params = {}
        params[:api_type] = 'json'
        request_data('/api/new_captcha', :post, params)
      end

      def captcha_iden
        request_data("/captcha/#{iden}", :get)
      end
    end
  end
end
