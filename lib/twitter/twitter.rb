module Twitter
  class << self
    # Reset session
    def reset!
      sessions.clear
      @username = nil
    end

    def use(username)
      @username = username
    end

    def save(filename=nil)
      store = Store.new(:sessions => sessions.values)
      store.filename = filename if filename
      store.save
    end

    def load(filename=nil)
      store = Store.new
      store.filename = filename if filename
      if store.load
        @sessions = store.sessions
        @username = @sessions.keys.first
      end
    end

    # Delegate method missing calls to session
    def method_missing(sym, *args, &blk)
      if authenticated? and delegating?(sym)
        current_session.send(sym, *args, &blk)
      else
        super
      end
    end

    # Check for presence of session or try to load saved session
    def authenticated?(loaded=false)
      return true if current_session and current_session.connected?
      if not loaded
        load
        authenticated?(true)
      end
    end

    # Create new session from passed credentials
    def authenticate(username, password)
      session = Session.new(username, password)
      session.connect!
      sessions[username] = session
      @username = username
    end

    # Load saved session from a .twitter file
    def load_session
      session = Session.new(nil, nil)
      if session.load
        @session = session ; true
      end
    end

    private

    def current_session
      sessions[@username]
    end

    def sessions
      @sessions ||= {}
    end

    # Check to see if Twitter is delegating this method to session
    def delegating?(sym)
      Session.public_instance_methods.include?(sym.to_s)
    end
  end
end
