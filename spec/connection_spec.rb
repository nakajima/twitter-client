require 'spec/spec_helper'

describe Twitter::Connection do
  it "belongs to session" do
    new_connection.session.should_not be_nil
  end

  it "authenticates using credentials from session" do
    expect_authorized do |responder|
      proc {
        new_connection.authenticate!
      }.should change(responder, :times).by(-1)
    end
  end

  it "raises API::Unauthorized error when credentials are invalid" do
    expect_unauthorized do |responder|
      proc {
        new_connection.authenticate!
      }.should raise_error(Twitter::API::Unauthorized)
    end
  end

  it "posts to paths" do
    expect_post('/foo/bar') do |responder|
      proc {
        new_connection.post('/foo/bar')
      }.should change(responder, :times).by(-1)
    end
  end
end
