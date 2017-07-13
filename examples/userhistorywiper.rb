require 'yaml'
require 'NeonRAW'

config = YAML.load_file('settings.yaml')
client = NeonRAW.script(
  username: config['username'],
  password: config['password'],
  client_id: config['client_id'],
  secret: config['secret'],
  user_agent: 'User history wiper by /u/SirNeon'
)

# Wiping your user history has never been so easy!
client.me.purge 'overview', months: 1
