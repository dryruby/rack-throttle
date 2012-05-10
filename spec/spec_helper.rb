require "rubygems"
require "bundler/setup"

require "rack/test"
require 'timecop'
require "rack/throttle"


Spec::Example::ExampleGroup.instance_eval do
  let(:target_app) { mock("Example Rack App", :call => [200, {}, "Example App Body"]) }
end

Spec::Matchers.define :show_allowed_response do
  match do |body|
    body.include?("Example App Body")
  end
  
  failure_message_for_should do
    "expected response to show the allowed response" 
  end 

  failure_message_for_should_not do
    "expected response not to show the allowed response" 
  end
  
  description do
    "expected the allowed response"
  end 
end

Spec::Matchers.define :show_throttled_response do
  match do |body|
    body.include?("Rate Limit Exceeded")
  end
  
  failure_message_for_should do
    "expected response to show the throttled response" 
  end 

  failure_message_for_should_not do
    "expected response not to show the throttled response" 
  end
  
  description do
    "expected the throttled response"
  end 
end
