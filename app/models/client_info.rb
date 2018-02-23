class ClientInfo < ActiveRecord::Base

  def self.get_primary
    if ClientInfo.count == 0
      client_info = ClientInfo.new
    else
      client_info = ClientInfo.first
    end
    return client_info
  end

end
