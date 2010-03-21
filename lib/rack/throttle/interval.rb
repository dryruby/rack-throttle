module Rack; module Throttle
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
      t1 = request_start_time(request)
      t0 = cache_get(key = cache_key(request)) rescue nil
      allowed = !t0 || (t1 - t0.to_f) >= minimum_interval
      begin
        cache_set(key, t1)
        allowed
      rescue => e
        # If an error occurred while trying to update the timestamp stored
        # in the cache, we will fall back to allowing the request through.
        # This prevents the Rack application blowing up merely due to a
        # backend cache server (Memcached, Redis, etc.) being offline.
        allowed = true
      end
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
end; end
