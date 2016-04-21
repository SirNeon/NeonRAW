require 'yaml'
require 'NeonRAW'

# Handles exceptions for Reddit shit.
# @!method reddit_exception_handling
# @param block [&block] The block to be executed.
def reddit_exception_handling
  include NeonRAW::Errors
  loop do
    begin
      yield
    rescue InvalidCredentials, InvalidOAuth2Credentials => error
      abort(error.message)
    rescue CouldntReachServer, ServiceUnavailable
      sleep(5) # Gotta wait a bit for Reddit's servers to situate themselves.
      redo
    end
  end
end

# Creates and authenticate the client.
# @!method login(config)
# @param config [Hash] The config data loaded from the settings.yaml file.
# @return [NeonRAW::Clients::Script] Returns the client object.
def login(config)
  print "Logging in...\r"
  reddit_exception_handling do
    client = NeonRAW.script(config['username'], config['password'],
                            config['client_id'], config['secret'],
                            user_agent: 'Crossposting bot by /u/SirNeon')
    return client
  end
end

# Fetches the submissions.
# @!method get_submissions(client, quantity)
# @param client [NeonRAW::Clients::Script] The client object.
# @param quantity [1..1000] The number of submissions to fetch.
# @return [NeonRAW::Objects::Listing] Returns a listing with the submissions.
def get_submissions(client, quantity)
  print "Getting submissions...\r"
  reddit_exception_handling do
    submissions = client.subreddit('programming').hot limit: quantity
    return submissions
  end
end

# Crossposts the submissions.
# @!method crosspost(client, submissions, post_here)
# @param client [NeonRAW::Clients::Script] The client object.
# @param submissions [NeonRAW::Objects::Listing] The submissions.
# @param post_here [String] The subreddit name where the submissions will be
#   crossposted to.
def crosspost(client, submissions, post_here)
  post_to = client.subreddit post_here
  # We want to mirror the queue of the subreddit we're crossposting from, so we
  # reverse the order of the listing.
  submissions.reverse!
  submissions.each_with_index do |submission, i|
    print "Working on submission #{i + 1} / #{submissions.length}...\r"
    reddit_exception_handling do
      title = submission.title
      post_to.submit title, text: submission.selftext if submission.selfpost?
      post_to.submit title, url: submission.url if submission.linkpost?
      break
    end
  end
end

def main
  config = YAML.load_file('settings.yaml')
  client = login(config)
  submissions = get_submissions(client, 5)
  crosspost(client, submissions, 'programming_mirror')
end

main
