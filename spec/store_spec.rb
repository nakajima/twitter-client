require 'spec/spec_helper'

describe Twitter::Store do
  def sessions_from_file
    @sessions_from_file ||= begin
      crypter = Crypt::Blowfish.new('twitter-crypt-key')
      conf = YAML.load_file(ENV['HOME'] + '/._twitter_test_')
      conf[:sessions].inject({}) do |res, (key, val)|
        password = crypter.decrypt_string(val)
        res[key] = new_session(key, password)
        res
      end
    end
  end

  it "saves sesssions" do
    first_session = new_session('first', 'password')
    second_session = new_session('second', 'password')

    store = new_store(:sessions => [first_session, second_session])
    store.save


    sessions_from_file['first'].should == first_session
    sessions_from_file['second'].should == second_session
  end

  it "persists username/password" do
    expect_authorized do
      session = new_session('foo', 'bar')

      store = new_store(:sessions => [session])
      store.save

      sessions_from_file['foo'].password.should == 'bar'
    end
  end

  it "encrypts password" do
    expect_authorized do
      session = new_session('foo', 'bar')
      store = new_store(:sessions => [session])
      store.save

      env = YAML.load_file(ENV['HOME'] + '/._twitter_test_')[:sessions]
      env['foo']['password'].should_not == 'bar'
    end
  end
end
