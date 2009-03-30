require 'rubygems'
require 'spec'
require 'fakeweb'
require 'rr'
require File.join(File.dirname(__FILE__), *%w[helpers fake_web])

require File.dirname(__FILE__) + '/../lib/twitter-client'

if $NO_CRYPT
  puts "You need the crypt gem to run the tests."
  exit 1
end

module ObjectGenerationMethods
  def new_store(config)
    store = Twitter::Store.new(config)
    store.filename = '._twitter_test_'
    store
  end

  def new_connection(session=new_session)
    Twitter::Connection.new(session)
  end

  def new_session(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    username = opts[:username] || args[0] || 'admin'
    password = opts[:password] || args[1] || 'password'
    Twitter::Session.new(username, password)
  end
end

module ResponseFakers
  def expect_authorized(body="", &block)
    expect_get('/account/verify_credentials', :status => ["200", ""], :string => body, &block)
  end

  def expect_unauthorized(&block)
    expect_get('/account/verify_credentials', :status => ["401", "Unauthorized"], &block)
  end

  def expect_tweet(text)
    expect_post('/statuses/update') do |responder, requests|
      yield responder
      CGI.parse(requests.first.body)['status'].to_s.should == text
    end
  end

  def expect_post(path, opts={}, &block)
    expect_request(:post, path, opts, &block)
  end

  def expect_get(path, opts={}, &block)
    expect_request(:get, path, opts, &block)
  end

  private

  def expect_request(verb, path, opts, &block)
    FakeWeb.requests(req = [])
    FakeWeb.register_uri(verb, "http://twitter.com" + "#{path}.json", opts)
    res = FakeWeb::Registry.instance.uri_map.values.first[verb].first

    return unless block_given?

    case block.arity
    when 1 then block.call(res)
    when 2 then block.call(res, req)
    else block.call
    end

    FakeWeb.clean_registry
  end
end

Spec::Runner.configure do |c|
  c.include ResponseFakers
  c.include ObjectGenerationMethods
  c.mock_with(:rr)
end

FakeWeb.allow_net_connect = false
