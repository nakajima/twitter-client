$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'nakajima'
require 'fileutils'
require 'net/http'
require 'yaml'
require 'crypt/blowfish'
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
    @session and @session.connected? or load_session
  end

  def self.authenticate(username, password)
    session = Session.new(username, password)
    session.connect!
    @session = session ; true
  end

  def self.load_session
    session = Session.new(nil, nil)
    if session.load
      @session = session ; true
    end
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
