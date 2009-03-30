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
require 'twitter/store'
require 'twitter/session'
require 'twitter/connection'
require 'twitter/twitter'

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
