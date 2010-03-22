require File.dirname(__FILE__) + '/spec_helper'

def app
  @target_app ||= example_target_app
  @app ||= Rack::Throttle::Interval.new(@target_app, :min => 0.1)
end

describe Rack::Throttle::Interval do
  include Rack::Test::Methods
  
  it "should allow the request if the source has not been seen" do
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should allow the request if the source has not been seen in the current interval" do
    get "/foo"
    sleep 0.2 # Should time travel this instead?
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should not all the request if the source has been seen inside the current interval" do
    2.times { get "/foo" }
    last_response.body.should show_throttled_response
  end
  
  it "should gracefully allow the request if the cache bombs on getting" do
    app.should_receive(:cache_get).and_raise(StandardError)
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should gracefully allow the request if the cache bombs on setting" do
    app.should_receive(:cache_set).and_raise(StandardError)
    get "/foo"
    last_response.body.should show_allowed_response
  end
end
