$LOAD_PATH << File.dirname(__FILE__)

# standard library
require 'rubygems'
require 'fileutils'
require 'net/http'
require 'yaml'
require 'cgi'

# Gems
require 'nakajima'
require 'crypt/blowfish'

# Extensions
require 'core_ext/delegation'

# Source files
require 'twitter/api'
require 'twitter/session'
require 'twitter/connection'

module Twitter
  class << self
    # Reset session
    def reset!
      @session = nil
    end

    # Delegate method missing calls to session
    def method_missing(sym, *args, &blk)
      if authenticated? and delegating?(sym)
        @session.send(sym, *args, &blk)
      else
        super
      end
    end

    private

    # Check to see if Twitter is delegating this method to session
    def delegating?(sym)
      @session.class.public_instance_methods.include?(sym.to_s)
    end
  end

  # Check for presence of session or try to load saved session
  def self.authenticated?
    @session and @session.connected? or load_session
  end

  # Create new session from passed credentials
  def self.authenticate(username, password)
    session = Session.new(username, password)
    session.connect!
    @session = session ; true
  end

  # Load saved session from a .twitter file
  def self.load_session
    session = Session.new(nil, nil)
    if session.load
      @session = session ; true
    end
  end
end

# Hpricot-y constant-method
def Twitter(*args, &block)
  if args.empty? and not block_given?
    Twitter
  else
    if args.length == 1
      Twitter.tweet!(*args)
    end
  end
end
