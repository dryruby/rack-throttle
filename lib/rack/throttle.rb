require 'rack'

module Rack
  module Throttle
    autoload :TimeWindow, 'rack/throttle/time_window'
    autoload :Daily,    'rack/throttle/daily'
    autoload :Hourly,   'rack/throttle/hourly'
    autoload :Interval, 'rack/throttle/interval'
    autoload :Limiter,  'rack/throttle/limiter'
    autoload :VERSION,  'rack/throttle/version'
  end
end
