require 'rack'

module Rack
  module Throttle
    autoload :Limiter, 'rack/throttle/limiter'
    autoload :VERSION, 'rack/throttle/version'
  end
end
