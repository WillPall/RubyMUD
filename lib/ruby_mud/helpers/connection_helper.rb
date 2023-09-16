class ConnectionHelper
  class << self
    def other_peers(excluded_client)
      RubyMUD.connected_clients.reject { |c| c == excluded_client }
    end
  end
end
