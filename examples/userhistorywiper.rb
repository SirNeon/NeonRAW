require 'yaml'
require 'NeonRAW'

config = YAML.load_file('settings.yaml')
client = NeonRAW.script(config['username'], config['password'],
                        config['client_id'], config['secret'],
                        user_agent: 'User history wiper by /u/SirNeon')

# Wiping your user history has never been so easy!
client.me.purge 'overview', months: 1
