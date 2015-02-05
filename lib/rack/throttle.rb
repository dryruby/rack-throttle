require 'rack'

module Rack
  module Throttle
    autoload :NullLoger,  'rack/throttle/null_logger'
    autoload :Limiter,    'rack/throttle/limiter'
    autoload :Interval,   'rack/throttle/interval'
    autoload :TimeWindow, 'rack/throttle/time_window'
    autoload :Burst,      'rack/throttle/burst'
    autoload :Daily,      'rack/throttle/daily'
    autoload :Hourly,     'rack/throttle/hourly'
    autoload :Minute,     'rack/throttle/minute'
    autoload :VERSION,    'rack/throttle/version'
  end
end
