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
        when /invalid_grant/i             then ExpiredCode
        when /wrong_password/i            then InvalidCredentials
        when /bad_captcha/i               then InvalidCaptcha
        when /ratelimit/i                 then RateLimited
        when /quota_filled/i              then QuotaFilled
        when /bad_css_name/i              then InvalidClassName
        when /too_old/i                   then Archived
        when /too_much_flair_css/i        then TooManyClassNames
        when /user_required/i             then AuthenticationRequired
        when /bad_flair_target/i          then BadFlairTarget
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
      when 413 then RequestTooLarge
      when 429 then RateLimited
      when 500 then InternalServerError
      when 502 then BadGateway
      when 503 then ServiceUnavailable
      when 504 then TimedOut
      when 520 then CouldntReachServer
      end
    end

    # Parses Reddit data for errors.
    # @!method parse_errors(data)
    # @param data [Array, Hash] The data.
    def parse_errors(data)
      # handles returns from toggleable methods
      assign_data_errors([]) if data.empty?
      if data.is_a?(Array) # handles returns from some flair methods
        # handles multireddits
        assign_data_errors([]) unless data[0].key?(:errors)
        messages = []
        errors = data[0][:errors]
        errors.each { |_key, error| messages << error } unless errors.empty?
        assign_data_errors(messages)
      elsif data.key?(:json) # handles pretty much everything else
        assign_data_errors([]) unless data[:json].key?(:errors)
        if data[:json][:errors].is_a?(Array)
          errors = data[:json][:errors][0] || []
          assign_data_errors(errors)
        else
          errors = data[:json][:errors] || []
          assign_data_errors(errors)
        end
      elsif data.key?(:errors) # handles image uploading
        errors = data[:errors] || []
        assign_data_errors(errors)
      elsif data.key?(:jquery) # handles submitting submissions
        data = data[:jquery]
        errors = data[14][3]
        errors = data[22][3] if errors.empty? && data.length > 20
        assign_data_errors(errors)
      end
    end

    # Checks data for any errors that wouldn't have otherwise thrown an
    # exception.
    # @!method assign_data_errors(errors)
    # @param errors [Array<String>] The errors.
    def assign_data_errors(errors)
      return nil if errors.empty?
      error = errors.first
      case error
      when /improperly formatted row/i then BadFlairRowFormat
      when /no_subject/i               then NoSubject
      when /too_long/i                 then TooLong
      when /no_text/i                  then NoText
      when /subreddit_noexist/i        then InvalidSubreddit
      when /user_muted/i               then UserMuted
      when /no_sr_to_sr_message/i      then InvalidSubreddit
      when /user_blocked/i             then UserBlocked
      when /muted_from_subreddit/i     then MutedFromSubreddit
      when /you aren't allowed/i       then PermissionDenied
      when /doesn't allow/i            then PermissionDenied
      when /url is required/i          then NoUrl
      when /already been submitted/i   then AlreadySubmitted
      when /no_invite_found/i          then NoInviteFound
      when /deleted_comment/i          then DeletedComment
      when /thread_locked/i            then PermissionDenied
      when /image_error/i              then ImageError
      when /subreddit_exists/i         then SubredditExists
      when /cant_create_sr/i           then CantCreateSubreddit
      when /invalid_option/i           then InvalidOption
      when /gold_required/i            then GoldRequired
      when /gold_only_sr_required/i    then GoldOnlySrRequired
      when /admin_required/i           then PermissionDenied
      when /bad_number/i               then BadNumber
      when /bad_sr_name/i              then BadSubredditName
      when /rows per call reached/i    then TooManyFlairRows
      when /unable to resolve user/i   then CouldntResolveUser
      when /sr_rule_exists/i           then RuleExists
      when /sr_rule_too_many/i         then TooManyRules
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

    # That URL has already been submitted.
    class AlreadySubmitted < StandardError
      def initialize(msg = 'That URL has already been submitted.')
        super(msg)
      end
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

    # The flair row you sent was invalid.
    # Should be: "Username,flairtext,CSSclass\nUsername,flairtext,CSSclass..."
    class BadFlairRowFormat < StandardError
      def initialize(msg = 'Improperly formatted row.')
        super(msg)
      end
    end

    # The thing you tried to flair was a bad target.
    class BadFlairTarget < StandardError
      def initialize(msg = 'Bad flair target.')
        super(msg)
      end
    end

    # Reddit's servers are shitting themselves.
    class BadGateway < StandardError
      def initialize(msg = "Reddit's server's are experiencing technical difficulties. Try again later.")
        super(msg)
      end
    end

    # The number value for a request parameter was incorrect.
    class BadNumber < StandardError
      def initialize(msg = 'The number passed to a request parameter was incorrect.')
        super(msg)
      end
    end

    # The request you sent to the API endpoint was bad.
    class BadRequest < StandardError
      def initialize(msg = 'The request you sent was incorrect. Please fix it.')
        super(msg)
      end
    end

    # The subreddit name was bad.
    class BadSubredditName < StandardError
      def initialize(msg = 'Bad subreddit name. Only [a-zA-Z0-9_] allowed.')
        super(msg)
      end
    end

    # Couldn't create the subreddit.
    class CantCreateSubreddit < StandardError
      def initialize(msg = "Couldn't create subreddit.")
        super(msg)
      end
    end

    # The multireddit you're trying to create already exists.
    class Conflict < StandardError
      def initialize(msg = "The multireddit you're trying to create already exists.")
        super(msg)
      end
    end

    # Reddit's servers are shitting themselves.
    class CouldntReachServer < StandardError
      def initialize(msg = "Reddit's servers are experiencing technical difficulties. Try again later.")
        super(msg)
      end
    end

    # Couldn't resolve the user provided.
    class CouldntResolveUser < StandardError
      def initialize(msg = "Couldn't resolve the user provided.")
        super(msg)
      end
    end

    # The comment you tried to reply to has been deleted.
    class DeletedComment < StandardError
      def initialize(msg = 'The comment you tried to reply to has been deleted.')
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

    # Only gold-only subreddits can do that.
    class GoldOnlySrRequired < StandardError
      def initialize(msg = 'Only gold-only subreddits can do that.')
        super(msg)
      end
    end

    # You need gold to do that.
    class GoldRequired < StandardError
      def initialize(msg = 'You need gold to do that.')
        super(msg)
      end
    end

    # The image you tried to upload wasn't valid.
    class ImageError < StandardError
      def initialize(msg = "The image you tried to upload wasn't valid.")
        super(msg)
      end
    end

    # Reddit's servers are shitting themselves.
    class InternalServerError < StandardError
      def initialize(msg = "Reddit's servers are experiencing technical difficulties. Try again later.")
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
      def initialize(msg = 'Invalid client_id/secret/access token.')
        super(msg)
      end
    end

    # Invalid option specified.
    class InvalidOption < StandardError
      def initialize(msg = 'One of the specified options is invalid.')
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

    # Your from_subreddit parameter was wrong.
    class InvalidSubreddit < StandardError
      def initialize(msg = "The subreddit you specified is invalid.")
        super(msg)
      end
    end

    # You are muted from the subreddit.
    class MutedFromSubreddit < StandardError
      def initialize(msg = 'User is muted from the subreddit.')
        super(msg)
      end
    end

    # No moderator invite was found.
    class NoInviteFound < StandardError
      def initialize(msg = 'No moderator invite found.')
        super(msg)
      end
    end

    # You tried to send a private message with no subject.
    class NoSubject < StandardError
      def initialize(msg = 'No message subject. Please add a message subject.')
        super(msg)
      end
    end

    # You tried to send a message with no text.
    class NoText < StandardError
      def initialize(msg = 'No message text. Please add message text.')
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

    # You didn't include an URL when submitting the submission.
    class NoUrl < StandardError
      def initialize(msg = 'No URL. Please add an URL.')
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
      def initialize(msg = "You don't have permission to do that.")
        super(msg)
      end
    end

    # This is like being RateLimited only more oAuth2-focused I think.
    class QuotaFilled < StandardError
      def initialize(msg = 'Your quota is filled. Try again later.')
        super(msg)
      end
    end

    # Gotta wait before making another request.
    class RateLimited < StandardError
      def initialize(msg = "You're rate limited. Try again later.")
        super(msg)
      end
    end

    # There was an error with your request.
    class RequestError < StandardError
      def initialize(msg = 'There was an error with your request.')
        super(msg)
      end
    end

    # The request you sent was too large.
    class RequestTooLarge < StandardError
      def initialize(msg = 'The request you sent was too large.')
        super(msg)
      end
    end

    # This rule already exists.
    class RuleExists < StandardError
      def initialize(msg = 'This rule already exists.')
        super(msg)
      end
    end

    # Reddit's servers are shitting themselves/down for maintenance.
    class ServiceUnavailable < StandardError
      def initialize(msg = "Reddit's servers are currently unavailable. Try again later.")
        super(msg)
      end
    end

    # The subreddit you tried to create already exists.
    class SubredditExists < StandardError
      def initialize(msg = 'The subreddit you tried to create already exists.')
        super(msg)
      end
    end

    # The connection timed out.
    class TimedOut < StandardError
      def initialize(msg = 'Your connection timed out.')
        super(msg)
      end
    end

    # The text you tried to submit was too long.
    class TooLong < StandardError
      def initialize(msg = 'The text you tried to send was too long. 10,000 characters maximum.')
        super(msg)
      end
    end

    # You have too many flair classes already.
    class TooManyClassNames < StandardError
      def initialize(msg = 'Maxiumum number of flair classes reached.')
        super(msg)
      end
    end

    # You sent too many flair rows.
    class TooManyFlairRows < StandardError
      def initialize(msg = 'Too many flair rows. 100 maximum.')
        super(msg)
      end
    end

    # You already have the maximum amount of rules.
    class TooManyRules < StandardError
      def initialize(msg = 'You already have the maximum amount of rules.')
        super(msg)
      end
    end

    # Usually happens when the subreddit you requested doesn't exist.
    class UnexpectedRedirect < StandardError
      def initialize(msg = 'The subreddit you requested does not exist.')
        super(msg)
      end
    end

    # The user you tried to message is blocked.
    class UserBlocked < StandardError
      def initialize(msg = "Can't message blocked users.")
        super(msg)
      end
    end

    # The user you tried to message is muted from the subreddit.
    class UserMuted < StandardError
      def initialize(msg = 'User is muted.')
        super(msg)
      end
    end
  end
end
