require 'spec_helper'

class Rack::Throttle::RequestMethod < Rack::Throttle::Second

  def max_per_second(request = nil)
    return (options[:max_per_second] || options[:max] || 1) unless request
    if request.request_method == "POST"
      4
    else
      10
    end
  end
  alias_method :max_per_window, :max_per_second

end

describe Rack::Throttle::RequestMethod do
  include Rack::Test::Methods

  include_context 'mock app'

  let(:app) { described_class.new(target_app) }

  it "should be allowed if not seen this second" do
    get "/foo"
    expect(last_response.body).to show_allowed_response
  end

  it "should be allowed if seen fewer than the max allowed per second" do
    4.times { get "/foo" }
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
