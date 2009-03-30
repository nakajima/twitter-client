# FakeWeb kind of sucks dude.
module FakeWeb
  def self.requests(setter=nil)
    if setter
      @requests = setter
    else
      @requests ||= []
    end
  end
  
  def clean_registry
    requests.clear
    Registry.instance.clean_registry
  end
end

module Net  #:nodoc: all
  class HTTP
    def self.socket_type
      FakeWeb::StubSocket
    end

    alias :original_net_http_request :request
    alias :original_net_http_connect :connect

    def request(request, body = nil, &block)
      protocol = use_ssl? ? "https" : "http"

      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/

      uri = "#{protocol}://#{self.address}:#{self.port}#{path}"
      method = request.method.downcase.to_sym

      if FakeWeb.registered_uri?(method, uri)
        @socket = Net::HTTP.socket_type.new
        FakeWeb.requests << request
        FakeWeb.response_for(method, uri, &block)
      elsif FakeWeb.allow_net_connect?
        original_net_http_connect
        original_net_http_request(request, body, &block)
      else
        raise FakeWeb::NetConnectNotAllowedError,
              "Real HTTP connections are disabled. Unregistered request: #{request.method} #{uri}"
      end
    end

    def connect
    end
  end

end