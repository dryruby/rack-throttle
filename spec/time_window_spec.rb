require 'spec_helper'

describe Rack::Throttle::TimeWindow do
  include Rack::Test::Methods

  describe 'with default config' do
    include_context 'mock app'
    let(:app) { Rack::Throttle::TimeWindow.new(target_app) }

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
    end
  end
end
