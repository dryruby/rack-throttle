module Rack module Throttle
  ##
  # This rate limiter strategy throttles by defining a minimum interval (by
  # default, 1 second) between subsequent allowed HTTP requests.
  class Interval < Limiter
    ##
    # Returns `true` if sufficient time (equal to or more than
    # {#minimum_interval}) has passed since the last request and the given
    # present `request`.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def allowed?(request)
      time    = request_start_time(request)
      key     = cache_key(request)
      allowed = !cache_has?(key) || (time - cache_get(key).to_f) >= minimum_interval
      cache_set(key, time)
      allowed
    end

    ##
    # Returns the required minimal interval (in terms of seconds) that must
    # elapse between two subsequent HTTP requests.
    #
    # @return [Float]
    def minimum_interval
      @min ||= (@options[:min] || 1.0).to_f
    end
  end
end end
