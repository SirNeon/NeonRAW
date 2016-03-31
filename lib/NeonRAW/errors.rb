# rubocop:disable all

module NeonRAW
  # Methods and classes for handling errors.
  module Errors
    # Reads the HTTP status of the Typhoeus response and gives an exception to
    # raise.
    # @!method assign_errors(response)
    # @param response [Typhoeus::Response] The response object.
    # @return [StandardError, nil] Returns either the exception or nil if there
    #   is none.
    def assign_errors(response)
      code = response.code
      body = response.body
      case code
      when 200
        case body
        when /access_denied/i             then OAuth2AccessDenied
        when /unsupported_response_type/i then InvalidResponseType
        when /unsupported_grant_type/i    then InvalidGrantType
        when /invalid_scope/i             then InvalidScope
        when /invalid_request/i           then InvalidRequest
        when /no_text/i                   then NoTokenGiven
        when /invalid_grant/i             then ExpiredCode
        when /wrong_password/i            then InvalidCredentials
        when /bad_captcha/i               then InvalidCaptcha
        when /ratelimit/i                 then RateLimited
        when /quota_filled/i              then QuotaFilled
        when /bad_css_name/i              then InvalidClassName
        when /too_old/i                   then Archived
        when /too_much_flair_css/i        then TooManyClassNames
        when /user_required/i             then AuthenticationRequired
        else nil # no exception to be raised
        end
      when 302 then UnexpectedRedirect
      when 400 then BadRequest
      when 401 then InvalidOAuth2Credentials
      when 403
        if /user_required/i =~ body
          AuthenticationRequired
        else
          PermissionDenied
        end
      when 404 then NotFound
      when 409 then Conflict
      when 500 then InternalServerError
      when 502 then BadGateway
      when 503 then ServiceUnavailable
      when 504 then TimedOut
      end
    end

    # Manages the API ratelimit for requesting stuff from Reddit.
    # @!method handle_ratelimit(headers)
    # @param headers [Hash] The Typhoeus response headers.
    def handle_ratelimit(headers)
      requests_remaining = headers['X-Ratelimit-Remaining'].to_i
      ratelimit_reset = headers['X-Ratelimit-Reset'].to_i
      sleep(ratelimit_reset) unless requests_remaining > 0
    end

    # Thing is archived and can't be edited/replied to.
    class Archived < StandardError
      def initialize(msg = 'This thing is too old to edit/reply to.')
        super(msg)
      end
    end

    # Client needs to be authorized.
    class AuthenticationRequired < StandardError
      def initialize(msg = 'The client must be authorized to do that.')
        super(msg)
      end
    end

    # Reddit's server's are shitting themselves.
    class BadGateway < StandardError
      def initialize(msg = "Reddit's server's are experiencing technical difficulties. Try again later.")
        super(msg)
      end
    end

    # The request you sent to the API endpoint was bad.
    class BadRequest < StandardError
      def initialize(msg = 'The request you sent was incorrect. Please fix it.')
        super(msg)
      end
    end

    # Request couldn't be processed because of conflict in the request, like if
    # there was multiple simultaneous updates.
    class Conflict < StandardError
      def initialize(msg = "Your request couldn't be processed because of a conflict in the request.")
        super(msg)
      end
    end

    # You already received an access token using this code. They're only good
    # for one use.
    class ExpiredCode < StandardError
      def initialize(msg = 'The code used to get the access token has expired.')
        super(msg)
      end
    end

    # Reddit's server's are shitting themselves.
    class InternalServerError < StandardError
      def initialize(msg = "Reddit's server's are experiencing technical difficulties. Try again later.")
        super(msg)
      end
    end

    # You got the captcha wrong.
    class InvalidCaptcha < StandardError
      def initialize(msg = 'Invalid captcha.')
        super(msg)
      end
    end

    # You got the requested CSS class name wrong.
    class InvalidClassName < StandardError
      def initialize(msg = 'Invalid CSS class name.')
        super(msg)
      end
    end

    # Your username/password is wrong.
    class InvalidCredentials < StandardError
      def initialize(msg = 'Invalid username/password')
        super(msg)
      end
    end

    # Your grant_type is wrong.
    class InvalidGrantType < StandardError
      def initialize(msg = 'Invalid grant_type.')
        super(msg)
      end
    end

    # Your client_id/secret is wrong or your access token expired.
    class InvalidOAuth2Credentials < StandardError
      def initialize(msg = 'Invalid client_id/secret.')
        super(msg)
      end
    end

    # The response_type parameter you sent was wrong. It should be the
    # string "code".
    class InvalidResponseType < StandardError
      def initialize(msg = 'Invalid response_type. Should be "code".')
        super(msg)
      end
    end

    # The parameters sent to /api/v1/authorize were wrong.
    class InvalidRequest < StandardError
      def initialize(msg = 'Invalid /api/v1/authorize parameters.')
        super(msg)
      end
    end

    # You don't have the right scope to perform the request.
    class InvalidScope < StandardError
      def initialize(msg = "You don't have the right scope to do that.")
        super(msg)
      end
    end

    # The thing you requested wasn't found. Could also mean that a user has
    # been shadowbanned or a subreddit has been banned.
    class NotFound < StandardError
      def initialize(msg = "The thing you requested couldn't be found.")
        super(msg)
      end
    end
    # No access token was given.
    class NoTokenGiven < StandardError
      def initialize(msg = 'No access token was provided.')
        super(msg)
      end
    end

    # The user chose not to grant your app access.
    class OAuth2AccessDenied < StandardError
      def initialize(msg = 'The user chose not to grant your app access.')
        super(msg)
      end
    end

    # You don't have adequate privileges to do that.
    class PermissionDenied < StandardError
      def initialize(msg = "You don't have adequate privileges to do that.")
        super(msg)
      end
    end

    # Gotta wait before making another request.
    class RateLimited < StandardError
      def initialize(msg = "You're rate limited. Try again later.")
        super(msg)
      end
    end

    # This is like being RateLimited only more oAuth2-focused I think.
    class QuotaFilled < StandardError
      def initialize(msg = 'Your quota is filled. Try again later.')
        super(msg)
      end
    end

    # There was an error with your request.
    class RequestError < StandardError
      def initialize(msg = 'There was an error with your request.')
        super(msg)
      end
    end

    # Reddit's server's are shitting themselves/down for maintenance.
    class ServiceUnavailable < StandardError
      def initialize(msg = "Reddit's server's are currently unavailable. Try again later.")
        super(msg)
      end
    end

    # The connection timed out.
    class TimedOut < StandardError
      def initialize(msg = 'Your connection timed out.')
        super(msg)
      end
    end

    # You have too many flair classes already.
    class TooManyClassNames < StandardError
      def initialize(msg = 'Maxiumum number of flair classes reached.')
        super(msg)
      end
    end

    # Usually happens when the subreddit you requested doesn't exist.
    class UnexpectedRedirect < StandardError
      def initialize(msg = 'The subreddit you requested does not exist.')
        super(msg)
      end
    end
  end
end
