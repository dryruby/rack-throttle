require 'rack'

module Rack
  module Throttle
    require_relative "throttle/limiter"
    require_relative "throttle/interval"
    require_relative "throttle/time_window"
    require_relative "throttle/daily"
    require_relative "throttle/hourly"
    require_relative "throttle/minute"
    require_relative "throttle/second"
    require_relative "throttle/version"
  end
end
