require 'spec_helper'

describe Rack::Throttle::Minute do
  include Rack::Test::Methods

  include_context 'mock app'

  let(:app) { described_class.new(target_app, :max_per_minute => 3) }

  it "should be allowed if not seen this minute" do
    get "/foo"
    expect(last_response.body).to show_allowed_response
  end

  it "should be allowed if seen fewer than the max allowed per minute" do
    2.times { get "/foo" }
    expect(last_response.body).to show_allowed_response
  end

  it "should not be allowed if seen more times than the max allowed per minute" do
    4.times { get "/foo" }
    expect(last_response.body).to show_throttled_response
  end

  [:minute_ago, :hour_ago, :day_ago].each do |time|
    it "should not count the requests from a #{time.to_s.split('_').join(' ')} against this minute" do
      Timecop.freeze(1.send(time)) do
        4.times { get "/foo" }
        expect(last_response.body).to show_throttled_response
      end

      get "/foo"
      expect(last_response.body).to show_allowed_response
    end
  end
end
