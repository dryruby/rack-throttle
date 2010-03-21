module Rack module Throttle
  ##
  # This rate limiter strategy throttles by defining a minimum interval (by
  # default, 1 second) between subsequent allowed HTTP requests.
  class Interval < Limiter
    # TODO
  end
end end
