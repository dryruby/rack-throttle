require 'spec_helper'

describe Rack::Throttle::Rules do
  include Rack::Test::Methods

  include_context 'mock app'

  mybot_check = Proc.new { |request|
    (request.env["HTTP_AGENT"] =~ /mybot/ ? "mybot" : false)
  }
  
  somebot_check = Proc.new { |request|
    (request.env["HTTP_AGENT"] =~ /somebot/ ? "somebot" : false)
  }

  let(:options) do
    {
      rules: [
        { method: "POST", limit: 5 },
        { method: "GET", limit: 3 },
        { method: "GET", path: "/bar/.*/muh", limit: 5 },
        { method: "GET", path: "/white/list/me", whitelisted: true },
        { method: "GET", path: "/bar/.*/window", limit: 3, time_window: :minute },
        { method: "GET", proc: somebot_check, limit: 8 },
        { method: "GET", proc: mybot_check, whitelisted: true }
      ],
      ip_whitelist: [
        "123.123.123.123"
      ],
      default: 10
    }
  end

  let(:app) { described_class.new(target_app, options) }
 
  describe "allowed" do
    
    it "should be allowed if not seen this second" do
      get "/bar/124/muh", {}, { "HTTP_AGENT" => "mybot" }
      expect(last_response.body).to show_allowed_response
    end
    
    it "should be allowed if not seen this second" do
      6.times { get "/bar/124/muh", {}, { "HTTP_AGENT" => "somebot" } }
      expect(last_response.body).to show_allowed_response
    end
    
    it "should be allowed if not seen this second" do
      10.times { get "/bar/124/muh", {}, { "HTTP_AGENT" => "mybot" } }
      expect(last_response.body).to show_allowed_response
    end

    it "should be allowed if not seen this second" do
      allow_any_instance_of(Rack::Throttle::Rules).to receive(:ip).and_return("123.123.123.123")
      10.times { get "/bar/124/muh" }
      expect(last_response.body).to show_allowed_response
    end
    
    it "should be allowed unlimited times" do
      100.times { get "/white/list/me" }
      expect(last_response.body).to show_allowed_response
    end
 
    it "should be allowed if not seen this second" do
      get "/bar/124/muh"
      expect(last_response.body).to show_allowed_response
    end
    
    it "should be allowed if not seen this second" do
      5.times { get "/bar/124/muh" }
      expect(last_response.body).to show_allowed_response
    end

    it "should be allowed if not seen this second" do
      get "/foo"
      expect(last_response.body).to show_allowed_response
    end

    it "should be allowed if seen fewer times than the max allowed per second" do
      3.times { get "/foo" }
      expect(last_response.body).to show_allowed_response
    end
    
    it "should be allowed if seen fewer times than the max allowed per second" do
      5.times { post "/foo" }
      expect(last_response.body).to show_allowed_response
    end

    it "should be allowed if seen fewer than the default limit" do
      9.times { put "/foo" }
      expect(last_response.body).to show_allowed_response
    end

    it "should be allowed if seen fewer times than the max allowed per time_window" do
      get "/bar/124/window"
      expect(last_response.body).to show_allowed_response
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

  describe "throttled" do

    it "should not be allowed if seen more times than the max allowed per second" do
      10.times { get "/foo" }
      expect(last_response.body).to show_throttled_response
    end
    
    it "should not be allowed if seen more times than the max allowed per second" do
      10.times { post "/foo" }
      expect(last_response.body).to show_throttled_response
    end
    
    it "should not be allowed if seen more times than the default defines" do
      15.times { put "/foo" }
      expect(last_response.body).to show_throttled_response
    end

    it "should not be allowed if seen more times than the max allowed per time_window" do
      Timecop.freeze(Time.now - Time.now.to_i % 60) do
        4.times { get "/bar/124/window" }
        expect(last_response.body).to show_throttled_response
      end

      get "/bar/124/window"
      expect(last_response.body).to show_throttled_response
    end
    
    it "should be allowed if not seen this second" do
      6.times { get "/bar/124/muh" }
      expect(last_response.body).to show_throttled_response
    end
    
    it "should be allowed if not seen this second" do
      allow_any_instance_of(Rack::Throttle::Rules).to receive(:ip).and_return("1.1.1.1")
      10.times { get "/bar/124/muh" }
      expect(last_response.body).to show_throttled_response
    end
    
    it "should be allowed if not seen this second" do
      10.times { get "/bar/124/muh", {}, { "HTTP_AGENT" => "somebot" } }
      expect(last_response.body).to show_throttled_response
    end

  end

end
