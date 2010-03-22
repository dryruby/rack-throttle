module Rack; module Throttle
  class TimeWindow < Limiter
    def allowed?(request)
      count = cache_get(key = cache_key(request)).to_i rescue nil
      allowed = !count || (count + 1) < max_per_window
      begin
        cache_set(key, count + 1)
        allowed
      rescue => e
        allowed = true
      end
    end
    
  end
end; end