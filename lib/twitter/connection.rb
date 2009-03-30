module Twitter
  class Connection
    VERIFY_PATH = '/account/verify_credentials'
    
    include Delegation
    
    attr_reader :session
    
    delegate :username, :password, :to => :session
    
    def initialize(session)
      @session = session
    end
    
    def get(path, params={})
      uri = uri_for(path)
      Net::HTTP::Get.new()
    end
    
    def post(path, params={})
      res = Net::HTTP.start(Twitter::API::BASE) do |http|
        req = Net::HTTP::Post.new(path + '.' + Twitter::API::FORMAT)
        req.basic_auth username, password
        req.set_form_data(params)
        res = http.request(req)
      end
    end
    
    def authenticate!
      @response ||= respond!
    end
    
    private
    
    def respond!
      @response ||= Net::HTTP.start(Twitter::API::BASE) do |http|
        req = Net::HTTP::Get.new(VERIFY_PATH + '.' + Twitter::API::FORMAT)
        req.basic_auth username, password
        
        case res = http.request(req)
        when Net::HTTPUnauthorized then raise API::Unauthorized.new
        else res
        end
      end
    end
  end
end