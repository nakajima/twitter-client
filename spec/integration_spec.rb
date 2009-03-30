require 'spec/spec_helper'

describe "Twitter Client at a high level" do
  before(:each) do
    Twitter.reset!
    FileUtils.rm("~/._twitter_test_") rescue nil
  end

  it "does not delegate private methods" do
    expect_authorized do
      Twitter.authenticate 'foozle', 'bizzle'
      proc {
        Twitter.password
      }.should raise_error(NoMethodError)
    end
  end

  describe "being authenticated" do
    # As a developer
    # in order interact with Twitter's API
    # I want to authenticate
    it "works by passing username & password to Twitter.authenticate" do
      stub(Twitter).load_session { false }

      expect_authorized do
        Twitter.should_not be_authenticated
        Twitter.authenticate 'foozle', 'bizzle'
        Twitter.should be_authenticated
      end

      expect_unauthorized do
        proc {
          Twitter.authenticate 'foozle', 'bizzle'
        }.should raise_error(Twitter::API::Unauthorized)
      end
    end
  end

  describe "posting a tweet" do
    before(:each) do
      expect_authorized do
        Twitter.authenticate 'test-user', 'password'
      end
    end

    it "posts a new tweet" do
      expect_tweet('This is stupid') do |responder, requests|
        proc {
          Twitter 'This is stupid'
        }.should change(responder, :times).by(-1)
      end
    end
  end

  describe "persisting data" do
    it "happens with Twitter.save()" do
      expect_authorized do
        Twitter.authenticate 'test-user', 'password'
        Twitter.save
        Twitter.reset!
        Twitter.should be_authenticated
      end
    end
  end
end
