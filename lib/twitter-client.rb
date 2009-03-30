$LOAD_PATH << File.dirname(__FILE__)

# standard library
require 'rubygems'
require 'fileutils'
require 'net/http'
require 'yaml'
require 'cgi'

# Gems
begin
  require 'crypt/blowfish'
rescue LoadError
  $NO_CRYPT = true
  # Fake encrypter if it's not available
  module Crypt
    class Blowfish
      def initialize(*args) end
      def decrypt_string(str); str end
      def encrypt_string(str); str end
    end
  end
  puts "  Warning!"
  puts
  puts "  The crypt/blowfish gem was not found."
  puts "  As a result, saved session file will not be encrypted."
  puts "  Run `gem install crypt` to install encryption libraries."
end

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
      Session.public_instance_methods.include?(sym.to_s)
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
