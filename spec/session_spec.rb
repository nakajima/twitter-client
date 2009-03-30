require 'spec/spec_helper'

describe Twitter::Session do
  before(:each) do
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
end