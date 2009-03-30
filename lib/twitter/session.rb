module Twitter
  class Session
    attr_reader :username, :password

    def initialize(username, password)
      @username, @password = username, password
    end

    def tweet!(msg)
      connection.post('/statuses/update', :status => msg) ; msg
    end

    def connect!
      connection(true)
    end

    def connected?
      !! @connection
    end

    private

    def connection(force=false)
      (@connection and not force) ? @connection : begin
        @connection = Connection.new(self)
        @connection.authenticate!
        @connection
      end
    end
  end
end
