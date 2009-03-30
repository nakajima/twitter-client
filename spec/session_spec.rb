require 'spec/spec_helper'

describe Twitter::Session do
  before(:each) do
    FileUtils.rm(ENV['HOME'] + "/._twitter_test_") rescue nil
    Twitter.reset!
  end

  it "connects via connection" do
    expect_authorized do
      session = new_session('foo', 'bar')

      mock.proxy(Twitter::Connection).new(session) do |connection|
        mock.proxy(connection).authenticate!
      end

      session.connect!
    end
  end

  it "knows if connected" do
    expect_authorized do
      session = new_session
      session.should_not be_connected

      session.connect!

      session.should be_connected
    end
  end

  describe "saving state" do
    it "saves state to file" do
      expect_authorized do
        session = new_session
        session.save
        File.exist?(File.join(ENV['HOME'], '._twitter_test_')).should be_true
      end
    end

    it "persists username/password" do
      expect_authorized do
        session = new_session('foo', 'bar')
        session.save

        config = YAML.load_file(ENV['HOME'] + '/._twitter_test_')
        config.should have_key(:username)
        config.should have_key(:password)
      end
    end

    it "encrypts username/password" do
      expect_authorized do
        session = new_session('foo', 'bar')
        session.save

        config = YAML.load_file(ENV['HOME'] + '/._twitter_test_')
        config[:username].should_not == 'foo'
        config[:password].should_not == 'bar'
      end
    end

    describe "loading state from file" do
      before(:each) do
        expect_authorized do
          session = new_session('foo', 'bar')
          session.save
        end
      end

      it "loads state from file" do
        session = new_session
        session.load
        session.username.should == 'foo'
        session.password.should == 'bar'
      end
    end
  end
end
