module Rack; module Throttle
  ##
  # This rate limiter strategy throttles the application by defining a
  # maximum number of allowed HTTP requests per day (by default, 86,400
  # requests per 24 hours, which works out to an average of 1 request per
  # second).
  #
  # This is rough as it doesn't have a sliding window, but rather tracks per
  # calendar day.  I can't think of a way to not have a gazillion timestamps
  # in the cache value, otherwise
  class Daily < TimeWindow
    def max_per_day
      @max_per_hour ||= @options[:max_per_day] || 86400
    end
    alias_method :max_per_window, :max_per_day
    
    protected

    ##
    # @param  [Rack::Request] request
    # @return [String]
    def cache_key(request)
      super + "_" + Time.now.strftime("%Y-%m-%d")
    end
  end
end; end
