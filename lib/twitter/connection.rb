module Twitter
  class Connection
    include Delegation

    attr_reader :session

    delegate :username, :password, :to => :session

    def initialize(session)
      @session = session
    end

    # Make GET request with HTTP auth
    def get(path, params={})
      request(:get, path, params)
    end

    # Make post request with HTTP auth
    def post(path, params={})
      request(:post, path, params) do |req|
        req.set_form_data(params)
      end
    end

    # Ensure authentication credentials are valid
    def authenticate!
      @response ||= get('/account/verify_credentials')
    end

    private

    # Wrap common request logic for POST/GET requests
    def request(verb, path, params)
      path = path + '.' + Twitter::API::FORMAT
      res = Net::HTTP.start(Twitter::API::BASE) do |http|
        req = Net::HTTP.const_get(verb.to_s.capitalize).new(path)
        req.basic_auth username, password
        yield req if block_given?
        res = http.request(req)
        check_response(res)
      end
    end

    # Ensure response is valid
    def check_response(res)
      case res
      when Net::HTTPUnauthorized then raise API::Unauthorized.new
      else res
      end
    end
  end
end
