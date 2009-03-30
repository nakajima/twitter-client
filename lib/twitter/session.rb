module Twitter
  # Most of the logic in twitter-client lives in here. Responsible
  # for maintaining/persisting credentials.
  class Session
    attr_reader :username
    attr_writer :filename

    def initialize(username, password)
      @username, @password = username, password
    end

    # Post a via the current session.
    # TODO The Session class should be infrastructural. Domain logic like
    #      this should go elsewhere.
    def tweet!(msg)
      connection.post('/statuses/update', :status => msg) ; msg
    end

    # Persist the current session to a dot file
    def save
      f = File.new(File.join(ENV['HOME'], filename), 'w+')
      f << yaml_dump
      f.close
    end

    # Attempt to load the current session from a dot file
    def load
      return false unless File.exist?(ENV['HOME'] + "/#{filename}")

      config = YAML.load_file(File.join(ENV['HOME'], filename))
      @username = crypter.decrypt_string(config[:username])
      @password = crypter.decrypt_string(config[:password])
      true
    end

    # Ensure validity of credentials
    def connect!
      connection(true)
    end

    # Provide verification that session is able to be used
    def connected?
      if @connection || load
        true
      end
    end

    # Allow custom name for dot file used to persist sessions
    def filename
      @filename || '.twitter'
    end

    private
    attr_reader :password

    def crypter
      @crypter ||= Crypt::Blowfish.new('twitter-crypt-key')
    end

    def yaml_dump
      {
        :username => crypter.encrypt_string(username),
        :password => crypter.encrypt_string(password)
      }.to_yaml
    end

    def connection(force=false)
      (@connection and not force) ? @connection : begin
        @connection = Connection.new(self)
        @connection.authenticate!
        @connection
      end
    end
  end
end
