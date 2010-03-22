module Rack; module Throttle
  class TimeWindow < Limiter
    def allowed?(request)
      count = cache_get(key = cache_key(request)).to_i + 1 rescue 1
      allowed = count <= max_per_window
      begin
        cache_set(key, count)
        allowed
      rescue => e
        allowed = true
      end
    end
    
  end
end; end