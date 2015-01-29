require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Burst do
  include Rack::Test::Methods

  def app
    @target_app ||= example_target_app
    @app ||= Rack::Throttle::Burst.new(@target_app, :logger => Logger.new(STDERR))
  end

  it "should be allowed if not seen this burst" do
    get "/foo"
    last_response.body.should show_allowed_response
  end
  
  it "should be allowed if seen fewer than the max allowed per burst within time window" do
    5.times { get "/foo" }
    last_response.body.should show_allowed_response

    Timecop.travel(Time.now + 10)
    5.times { get "/foo" }
    last_response.body.should show_allowed_response

    Timecop.travel(Time.now + 10)
    5.times { get "/foo" }
    last_response.body.should show_allowed_response
  end
  
  it "should not be allowed if seen more times than the max allowed per burst within time window" do
    15.times { get "/foo" }
    last_response.body.should show_throttled_response

    Timecop.travel(Time.now + 3)

    get "/foo"
    last_response.body.should show_throttled_response
  end

  it "should not be allowed for configured amount of secs after being banned" do
    8.times { get "/foo" }
    last_response.body.should show_allowed_response

    Timecop.travel(Time.now + 3)
    3.times { get "/foo" }
    last_response.body.should show_throttled_response

    Timecop.travel(Time.now + 50)
    1.times { get "/foo" }
    last_response.body.should show_throttled_response

    Timecop.travel(Time.now + 10)
    1.times { get "/foo" }
    last_response.body.should show_allowed_response
  end
  
end
