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

  it "should not count last minutes requests against today" do
    Timecop.freeze(DateTime.now - 1/24.0/60.0) do
      4.times { get "/foo" }
      expect(last_response.body).to show_throttled_response
    end

    get "/foo"
    expect(last_response.body).to show_allowed_response
  end
end
