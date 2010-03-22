require "spec"
require "rack/test"
require "rack/throttle"
require "webrat"

module ThrottleHelpers
  def request_is_allowed
    last_response.body.should contain("Example App Body")
  end
  
  def request_is_throttled
    last_response.body.should contain("Rate Limit Exceeded")
  end  
end

def example_target_app
  @target_app ||= mock("Example Rack App")
  @target_app.stub!(:call).and_return([200, {}, "Example App Body"])
end