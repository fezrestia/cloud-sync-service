module Https
  class << self # Export these APIs as class method.

    # HTTPS GET.
    #
    # @path URI
    # @return HttpResponse
    #
    def get(path)
      uri = URI.parse(path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      return response
    end

    # HTTPS PUT.
    #
    # @path URI
    # @json
    # @return HttpResponse
    #
    def put(path, json)
      uri = URI.parse(path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = json

      response = http.request(request)

      return response
    end

  end
end

