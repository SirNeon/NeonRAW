# rubocop:disable Style/FileName
require 'NeonRAW/version'
require 'NeonRAW/clients/script'

# le module
module NeonRAW
  def self.new(username, password, client_id, secret, opts = {})
    Script.new(username, password, client_id, secret, opts)
  end
end
