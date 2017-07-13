require 'yaml'
require 'NeonRAW'

# Creates and authenticates the client.
# @!method login(config)
# @param config [Hash] The data loaded from settings.yaml.
# @return [NeonRAW::Clients::Script] Returns the client.
def login(config)
  reddit_exception_handling do
    client = NeonRAW.script(
      username: config['username'],
      password: config['password'],
      client_id: config['client_id'],
      secret: config['secret'],
      user_agent: 'Flairbot by /u/SirNeon'
    )
    return client
  end
end

# Flairs submissions based on keywords in their title.
# @!method flair_shit(client, subreddit)
# @param client [NeonRAW::Clients::Script] The client.
# @param subreddit [String] The subreddit to scan.
def flair_shit(client, subreddit)
  reddit_exception_handling do
    subreddit = client.subreddit subreddit
    submissions = subreddit.new limit: 100
    submissions.each do |submission|
      next if submission.flair?
      case submission.title
      when /\[meta\]/i then subreddit.set_flair submission, 'Meta',
                                                css_class: 'meta'
      when /test/i then subreddit.set_flair submission, 'Test'
      end
    end
    break
  end
end

# Handles Reddit exceptions.
# @!method reddit_exception_handling
# @param block [&block] The block to execute.
def reddit_exception_handling
  include NeonRAW::Errors
  loop do
    begin
      yield
    rescue InvalidCredentials, InvalidOAuth2Credentials => error
      abort(error.message)
    rescue CouldntReachServer, ServiceUnavailable
      sleep(5)
      redo
    end
  end
end

def main
  config = YAML.load_file('settings.yaml')
  client = login(config)
  flair_shit client, client.me.name
end

main
