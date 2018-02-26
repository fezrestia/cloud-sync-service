module NotifyFcm extend self
  require 'net/https'

  # Request to notify device via Notification message.
  #
  # @titleStr Title string
  # @contentStr Content string
  # @data_hash Data notification key/value.
  # @return Response
  #
  def notifyToDeviceMsg(titleStr, contentStr)
    client_info = ClientInfo.get_primary
    fcm_token = client_info.fcm_token
    return nil if fcm_token.nil?

    payload = <<-"JSON"
{
  "notification": {
      "title": "#{titleStr}",
      "text": "#{contentStr}"
  },
  "to": "#{fcm_token}"
}
    JSON

    response = doNotify(payload)

    return response
  end

  # Request to nofity device via Data message.
  #
  # @data_hash
  # @return Response
  #
  def notifyToDeviceData(data_hash)
    client_info = ClientInfo.get_primary
    fcm_token = client_info.fcm_token
    return nil if fcm_token.nil?

    data_str = ''
    data_hash.each { |key, value|
      data_str += "\"#{key}\": \"#{value}\","
    }

    payload = <<-"JSON"
{
  "data": {
    #{data_str}
  },
  "to": "#{fcm_token}"
}
    JSON

    response = doNotify(payload)

    return response
  end

  private

    def doNotify(payload)
      uri = URI.parse("https://fcm.googleapis.com/fcm/send")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "key=#{ENV['FCM_TOKEN']}"

      request.body = payload

      response = http.request(request)

      return response
    end

  # private

end

