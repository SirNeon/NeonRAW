require 'yaml'
require 'NeonRAW'

# Creates and authenticates the client.
# @!method login(config)
# @param config [Hash] The data loaded from the settings.yaml file.
# @return [NeonRAW::Clients::Script] Returns the client.
def login(config)
  reddit_exception_handling do
    client = NeonRAW.script(
      username: config['username'],
      password: config['password'],
      client_id: config['client_id'],
      secret: config['secret'],
      user_agent: 'Public mod logger by /u/SirNeon'
    )
    return client
  end
end

# Fetches the modlog.
# @!method get_modlog(client, subreddit)
# @param client [NeonRAW::Clients::Script] The client.
# @param subreddit [String] The subreddit to fetch the modlog from.
# @return [NeonRAW::Objects::Listing] Returns the modlog actions.
def get_modlog(client, subreddit)
  reddit_exception_handling do
    subreddit = client.subreddit subreddit
    modlog = subreddit.modlog limit: 100
    return modlog.reverse
  end
end

# Submits the modlog data to Reddit.
# @!method submit_actions(client, subreddit, modlog)
# @param client [NeonRAW::Clients::Script] The client.
# @param subreddit [String] The subreddit to submit the data to.
# @param modlog [NeonRAW::Objects::Listing] The modlog actions.
def submit_actions(client, subreddit, modlog)
  reddit_exception_handling do
    subreddit = client.subreddit subreddit
    modlog.each do |entry|
      title = entry.id
      text = "Mod: #{entry.mod}\n\n"
      text += "Action: #{entry.action}\n\n"
      text += "Description: #{entry.description}\n\n" if entry.description
      text += "Created: #{entry.created}\n\n"
      text += "Target Author: #{entry.target_author}\n\n" if entry.target_author
      if entry.target_permalink
        text += "Target Permalink: #{entry.target_permalink}\n\n"
      end
      submission = subreddit.submit title, text: text
      subreddit.set_flair submission, entry.action
    end
    break
  end
end

# Handles Reddit exceptions.
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
      sleep(5)
      redo
    end
  end
end

def main
  config = YAML.load_file('settings.yaml')
  client = login(config)
  modlog = get_modlog(client, 'NeonRAW')
  submit_actions(client, 'NeonRAW', modlog)
end

main
