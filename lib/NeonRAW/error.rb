# rubocop:disable all

module NeonRAW
  # Methods and classes for handling errors.
  module Error
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
        when /access_denied/i then OAuth2AccessDenied
        when /unsupported_response_type/i then InvalidResponseType
        when /unsupported_grant_type/i then InvalidGrantType
        when /invalid_scope/i then InvalidScope
        when /invalid_request/i then InvalidRequest
        when /no_text/i then NoTokenGiven
        when /invalid_grant/i then ExpiredCode
        when /wrong_password/i then InvalidCredentials
        when /bad_captcha/i then InvalidCaptcha
        when /ratelimit/i then RateLimited
        when /quota_filled/i then QuotaFilled
        when /bad_css_name/i then InvalidClassName
        when /too_old/i then Archived
        when /too_much_flair_css/i then TooManyClassNames
        when /user_required/i then AuthenticationRequired
        else nil # no exception to be raised
        end
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
      when 503 then ServiceUnAvailable
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
    Archived = Class.new(StandardError)

    # Client needs to be authorized.
    AuthenticationRequired = Class.new(StandardError)

    # Reddit's server's are shitting themselves.
    BadGateway = Class.new(StandardError)

    # The request you sent to the API endpoint was bad.
    BadRequest = Class.new(StandardError)

    # Request couldn't be processed because of conflict in the request, like if
    # there was multiple simultaneous updates.
    Conflict = Class.new(StandardError)

    # You already received an access token using this code. They're only good
    # for one use.
    ExpiredCode = Class.new(StandardError)

    # Reddit's server's are shitting themselves.
    InternalServerError = Class.new(StandardError)

    # You got the captcha wrong.
    InvalidCaptcha = Class.new(StandardError)

    # You got the requested CSS class name wrong.
    InvalidClassName = Class.new(StandardError)

    # Your username/password is wrong.
    InvalidCredentials = Class.new(StandardError)

    # Your grant_type is wrong.
    InvalidGrantType = Class.new(StandardError)

    # Your client_id/secret is wrong or your access token expired.
    InvalidOAuth2Credentials = Class.new(StandardError)

    # The response_type parameter you sent was wrong. It should be the
    # string "code".
    InvalidResponseType = Class.new(StandardError)

    # The parameters sent to /api/v1/authorize were wrong.
    InvalidRequest = Class.new(StandardError)

    # You don't have the right scope to perform the request.
    InvalidScope = Class.new(StandardError)

    # The thing you requested wasn't found. Could also mean that a user has
    # been shadowbanned or a subreddit has been banned.
    NotFound = Class.new(StandardError)

    # No access token was given.
    NoTokenGiven = Class.new(StandardError)

    # The user chose not to grant your app access.
    OAuth2AccessDenied = Class.new(StandardError)

    # You don't have adequate privileges to do that.
    PermissionDenied = Class.new(StandardError)

    # Gotta wait before making another request.
    RateLimited = Class.new(StandardError)

    # This is like being RateLimited only more oAuth2-focused I think.
    QuotaFilled = Class.new(StandardError)

    # There was an error with your request.
    RequestError = Class.new(StandardError)

    # Reddit's server's are shitting themselves/down for maintenance.
    ServiceUnAvailable = Class.new(StandardError)

    # The connection timed out.
    TimedOut = Class.new(StandardError)

    # You have too many flair classes already.
    TooManyClassNames = Class.new(StandardError)
  end
end
