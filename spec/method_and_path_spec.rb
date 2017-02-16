require 'spec_helper'

describe Rack::Throttle::MethodAndPath do
  include Rack::Test::Methods

  include_context 'mock app'

  let(:options) do
    {
      limits: {
        "methods" => {
          "POST" => 5,
          "GET"  => 10
        },
        "paths"   => {},
        "default" => 10
      }
    }
  end

  let(:app) { described_class.new(target_app, options) }

  it "should be allowed if not seen this second" do
    get "/foo"
    expect(last_response.body).to show_allowed_response
  end

  it "should be allowed if seen fewer than the max allowed per second" do
    10.times { get "/foo" }
    expect(last_response.body).to show_allowed_response
  end
  
  it "should be allowed if seen fewer than the max allowed per second" do
    5.times { post "/foo" }
    expect(last_response.body).to show_allowed_response
  end

  it "should not be allowed if seen more times than the max allowed per second" do
    20.times { get "/foo" }
    expect(last_response.body).to show_throttled_response
  end
  
  it "should not be allowed if seen more times than the max allowed per second" do
    10.times { post "/foo" }
    expect(last_response.body).to show_throttled_response
  end

  [:second_ago, :minute_ago, :hour_ago, :day_ago].each do |time|
    it "should not count the requests from a #{time.to_s.split('_').join(' ')} against this second" do
      Timecop.freeze(1.send(time)) do
        20.times { get "/foo" }
        expect(last_response.body).to show_throttled_response
      end

      get "/foo"
      expect(last_response.body).to show_allowed_response
    end
  end
end
