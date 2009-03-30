$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'nakajima'
require 'net/http'
require 'cgi'

require 'core_ext/delegation'
require 'twitter/api'
require 'base'
require 'twitter/session'
require 'twitter/connection'

module Twitter
  class << self
    def reset!
      @session = nil
    end

    def method_missing(sym, *args, &blk)
      @session.respond_to?(sym) ?
        @session.send(sym, *args, &blk) : super
    end
  end

  def self.authenticated?
    @session && @session.connected?
  end

  def self.authenticate(username, password)
    session = Session.new(username, password)
    session.connect!
    @session = session
  end
end

def Twitter(*args, &block)
  if args.empty? and not block_given?
    Twitter
  else
    if args.length == 1
      Twitter.tweet!(*args)
    end
  end
end
