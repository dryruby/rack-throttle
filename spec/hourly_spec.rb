require 'spec_helper'

describe Rack::Throttle::Hourly do
  include Rack::Test::Methods

  include_context 'mock app'

  let(:app) { described_class.new(target_app, :max_per_hour => 3) }

  it "should be allowed if not seen this hour" do
    get "/foo"
    expect(last_response.body).to show_allowed_response
  end

  it "should be allowed if seen fewer than the max allowed per hour" do
    2.times { get "/foo" }
    expect(last_response.body).to show_allowed_response
  end

  it "should not be allowed if seen more times than the max allowed per hour" do
    4.times { get "/foo" }
    expect(last_response.body).to show_throttled_response
  end

  [:hour_ago, :day_ago].each do |time|
    it "should not count the requests from a #{time.to_s.split('_').join(' ')} against this hour" do
      Timecop.freeze(1.send(time)) do
        4.times { get "/foo" }
        expect(last_response.body).to show_throttled_response
      end

      get "/foo"
      expect(last_response.body).to show_allowed_response
    end
  end
end
