module Rack; module Throttle
  ##
  # This rate limiter strategy throttles the application by defining a
  # maximum number of allowed HTTP requests per hour (by default, 3,600
  # requests per 60 minutes, which works out to an average of 1 request per
  # second).
  #
  class Hourly < TimeWindow
    def max_per_hour
      @max_per_hour ||= @options[:max_per_hour] || 3600
    end
    alias_method :max_per_window, :max_per_hour
    
    protected
    
    ##
    # @param  [Rack::Request] request
    # @return [String]
    def cache_key(request)
      super + "_" + Time.now.strftime("%Y-%m-%d-%H")
    end
  end
end; end
