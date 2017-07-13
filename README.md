# NeonRAW

NeonRAW is an API wrapper for [Reddit](https://www.reddit.com) written in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'NeonRAW'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install NeonRAW

## Usage

Just require the gem at the top of your file.

```ruby
require 'NeonRAW'
```

## Samples

```ruby
# Make a web app.
client = NeonRAW.web(
  client_id: 'client_id',
  secret: 'secret',
  redirect_uri: 'redirect_uri',
  user_agent: 'test'
)

url = client.auth_url('state', ['identity', 'read'], 'permanent')
puts "Go to #{url} and enter the code below: "
code = gets.chomp
client.authorize! code

# Make a script app. Script apps automatically authorize themselves for you.
client = NeonRAW.script(
  username: 'username',
  password: 'password',
  client_id: 'client_id',
  secret: 'secret',
  user_agent: 'test'
)

# Fetch some submissions from /r/programming's hot queue.
subreddit = client.subreddit 'programming'
submissions = subreddit.hot limit: 10

submissions.each_with_index do |submission, i|
  puts "#{i + 1}: #{submission.title}"
end

# Fetch a user and message them if they're a friend.
user = client.user 'SirNeon'
user.message 'Hi.', "How's it going?" if user.friend?

# Fetch yourself and check your orangereds if you have mail.
myself = client.me
new_messages = myself.inbox limit: myself.inbox_count if myself.mail?
```

## Contributing

[See here](https://gitlab.com/SirNeon/NeonRAW/blob/master/CONTRIBUTING.md).
