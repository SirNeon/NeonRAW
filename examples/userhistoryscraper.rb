require 'yaml'
require 'NeonRAW'

# Creates and authenticates the client.
# @!method login(config)
# @param config [Hash] The data loaded from the settings.yaml file.
# @return [NeonRAW::Clients::Script] Returns the client.
def login(config)
  reddit_exception_handling do
    client = NeonRAW.script(config['username'], config['password'],
                            config['client_id'], config['secret'],
                            user_agent: 'User history scraper by /u/SirNeon')
    return client
  end
end

# Fetches the posts of the user.
# @!method get_posts(client, user, quantity)
# @param client [NeonRAW::Clients::Script] The client.
# @param user [String] The username of the user.
# @param quantity [1..1000] The number of posts to fetch.
# @return [NeonRAW::Objects::Listing] Returns the posts.
def get_posts(client, user, quantity)
  reddit_exception_handling do
    posts = client.user(user).overview limit: quantity
    return posts
  end
end

# Tallies the number of posts/karma per subreddit.
# @!method tally_data(posts)
# @param posts [NeonRAW::Objects::Listing] The posts.
# @return [Hash<Integer, Integer>] Returns the tallied data.
def tally_data(posts)
  stats = {}
  posts.each do |post|
    subreddit = post.subreddit
    stats[subreddit] = { posts: 0, karma: 0 } if stats[subreddit].nil?
    stats[subreddit][:posts] += 1
    stats[subreddit][:karma] += post.score
  end
  stats
end

# Sorts the data.
# @!method sort_data(data, by)
# @param data [Hash] The data.
# @param by [Symbol] The thing to sort by [posts, karma].
# @return [Hash<Integer, Integer>] Returns the sorted data.
def sort_data(data, by)
  # Sort the data highest amount of posts/karma to least amount.
  data.sort_by { |_subreddit, tallies| tallies[by] }.reverse.to_h
end

# Builds a table from the sorted data.
# @!method build_table(data)
# @param data [Hash] The data.
# @return [String] Returns the table.
def build_table(data)
  text = "|subreddit|posts|karma|\n|:---|:---:|:---:|\n"
  data.each do |subreddit, tallies|
    text += "|#{subreddit}|#{tallies[:posts]}|#{tallies[:karma]}|\n"
  end
  text
end

# Submits the results to Reddit.
# @!method submit_results(client, subreddit, title, text)
# @param client [NeonRAW::Objects::Script] The client.
# @param subreddit [String] The name of the subreddit to submit to.
# @param title [String] The title of the thread.
# @param text [String] The table to be submitted.
def submit_results(client, subreddit, title, text)
  reddit_exception_handling do
    client.subreddit(subreddit).submit title, text: text
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
  user = client.me.name
  posts = get_posts(client, user, 1000)
  data = tally_data(posts)
  sorted_data = sort_data(data, :posts)
  text = build_table(sorted_data)
  submit_results(client, user, "#{user}'s user history", text)
end

main
