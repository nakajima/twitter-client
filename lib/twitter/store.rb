module Twitter
  class Store
    attr_writer :filename

    def initialize(env={})
      @env = env
      @sessions = @env[:sessions]
    end

    # Persist the current session to a dot file
    def save
      f = File.new(File.join(ENV['HOME'], filename), 'w+')
      f << yaml_dump
      f.close
    end

    # Attempt to load the current session from a dot file
    def load
      YAML.load_file(File.join(ENV['HOME'], filename)) || {}
    end

    # Allow custom name for dot file used to persist sessions
    def filename
      @filename || '.twitter'
    end

    def sessions
      @sessions ||= begin
        load[:sessions].inject({}) do |res, (key, val)|
          password = crypter.decrypt_string(val)
          res[key] = Session.new(key, password, :connected => true)
          res
        end
      end
    end

    private

    def crypter
      @crypter ||= Crypt::Blowfish.new('twitter-crypt-key')
    end

    def yaml_dump
      session_data = sessions.inject({}) do |res, session|
        res[session.username] = crypter.encrypt_string(session.password)
        res
      end


      {
        :sessions => session_data
      }.to_yaml
    end
  end
end
