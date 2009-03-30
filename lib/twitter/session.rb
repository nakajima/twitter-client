module Twitter
  class Session
    attr_reader :username, :password
    attr_writer :filename

    def initialize(username, password)
      @username, @password = username, password
    end

    def tweet!(msg)
      connection.post('/statuses/update', :status => msg) ; msg
    end

    def save
      f = File.new(File.join(ENV['HOME'], filename), 'w+')
      f << yaml_dump
      f.close
    end

    def load
      return false unless File.exist?(ENV['HOME'] + "/#{filename}")

      config = YAML.load_file(File.join(ENV['HOME'], filename))
      @username = crypter.decrypt_string(config[:username])
      @password = crypter.decrypt_string(config[:password])
      true
    end

    def connect!
      connection(true)
    end

    def connected?
      if @connection || load
        true
      end
    end

    def filename
      @filename || '.twitter'
    end

    private

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
