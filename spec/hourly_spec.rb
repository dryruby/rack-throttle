require File.dirname(__FILE__) + '/spec_helper'

def app
  @target_app ||= example_target_app
  @app ||= Rack::Throttle::Hourly.new(@target_app, :max_per_hour => 3)
end

describe Rack::Throttle::Hourly do
  include Rack::Test::Methods
  include Webrat::Matchers
  include ThrottleHelpers

  it "should be allowed if not seen this hour" do
    get "/foo"
    request_is_allowed
  end
  
  it "should be allowed if seen fewer than the max allowed per hour" do
    2.times { get "/foo" }
    request_is_allowed
  end
  
  it "should not be allowed if seen more times than the max allowed per hour" do
    4.times { get "/foo" }
    request_is_throttled
  end
  
  # TODO mess with time travelling and requests to make sure no overlap
end
