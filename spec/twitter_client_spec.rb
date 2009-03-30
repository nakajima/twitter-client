require 'spec/spec_helper'

describe Twitter do
  before(:each) do
    Twitter.reset!
  end
  
  it "should exist" do
    proc {
      Twitter
    }.should_not raise_error
  end
  
  describe "authentication" do
    context "when not logged in" do
      it "is not authenticated" do
        Twitter.should_not be_authenticated
      end
    end
  end
end