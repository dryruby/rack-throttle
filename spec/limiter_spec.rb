require 'spec_helper'

describe Rack::Throttle::Limiter do
  include Rack::Test::Methods

  describe 'with default config' do
    include_context 'mock app'
    let(:app) { Rack::Throttle::Limiter.new(target_app) }

    describe "basic calling" do
      it "should return the example app" do
        get "/foo"
        expect(last_response.body).to show_allowed_response
      end

      it "should call the application if allowed" do
        expect(app).to receive(:allowed?).and_return(true)
        get "/foo"
        expect(last_response.body).to show_allowed_response
      end

      it "should give a rate limit exceeded message if not allowed" do
        expect(app).to receive(:allowed?).and_return(false)
        get "/foo"
        expect(last_response.body).to show_throttled_response
      end
    end

    describe "allowed?" do
      it "should return true if whitelisted" do
        expect(app).to receive(:whitelisted?).and_return(true)
        get "/foo"
        expect(last_response.body).to show_allowed_response
      end

      it "should return false if blacklisted" do
        expect(app).to receive(:blacklisted?).and_return(true)
        get "/foo"
        expect(last_response.body).to show_throttled_response
      end

      it "should return true if not whitelisted or blacklisted" do
        expect(app).to receive(:whitelisted?).and_return(false)
        expect(app).to receive(:blacklisted?).and_return(false)
        get "/foo"
        expect(last_response.body).to show_allowed_response
      end
    end
  end

  describe 'with rate_limit_exceeded callback' do
    include_context 'mock app'

    let(:app) { Rack::Throttle::Limiter.new(target_app, :rate_limit_exceeded_callback => lambda {|request| app.callback(request) } ) }

    it "should call rate_limit_exceeded_callback w/ request when rate limit exceeded" do
      expect(app).to receive(:blacklisted?).and_return(true)
      expect(app).to receive(:callback).and_return(true)
      get "/foo"
      expect(last_response.body).to show_throttled_response
    end
  end
end
