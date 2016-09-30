RSpec::Matchers.define :show_allowed_response do
  match do |body|
    body.include?("Example App Body")
  end

  failure_message do
    "expected response to show the allowed response"
  end

  failure_message_when_negated do
    "expected response not to show the allowed response"
  end

  description do
    "expected the allowed response"
  end
end

RSpec::Matchers.define :show_throttled_response do
  match do |body|
    body.include?("Rate Limit Exceeded")
  end

  failure_message do
    "expected response to show the throttled response"
  end

  failure_message_when_negated do
    "expected response not to show the throttled response"
  end

  description do
    "expected the throttled response"
  end
end
