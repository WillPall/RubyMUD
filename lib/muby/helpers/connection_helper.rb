class Muby::ConnectionHelper
  class << self
    def other_peers(excluded_client)
      Muby::Connection.connected_clients.reject { |c| c == excluded_client }
    end
  end
end
