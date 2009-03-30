module Twitter
  # Most of the logic in twitter-client lives in here. Responsible
  # for maintaining/persisting credentials.
  class Session
    attr_reader :username, :password
    attr_writer :filename

    def initialize(username, password, opts={})
      @username, @password = username, password
      @connection = opts[:connected] ? Connection.new(self) : nil
    end

    # Post a via the current session.
    # TODO The Session class should be infrastructural. Domain logic like
    #      this should go elsewhere.
    def tweet!(msg)
      connection.post('/statuses/update', :status => msg) ; msg
    end

    # Ensure validity of credentials
    def connect!
      connection(true)
    end

    # Provide verification that session is able to be used
    def connected?
      if @connection
        true
      end
    end

    def ==(other)
      [username, password] == [other.username, other.password]
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
