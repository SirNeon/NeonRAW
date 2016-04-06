# rubocop:disable Style/FileName
require 'NeonRAW/version'
require 'NeonRAW/clients/script'

# le module
module NeonRAW
  def self.script(username, password, client_id, secret, opts = {})
    Clients::Script.new(username, password, client_id, secret, opts)
  end
end
