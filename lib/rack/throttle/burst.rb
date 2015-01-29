require 'oj'

module Rack; module Throttle
  ##
  # This rate limiter strategy throttles the application by enforcing a
  # maximum amount of subsequent allowed HTTP requests within a sliding
  # window of time. When reached the client will be banned for a configurable
  # number of seconds.
  #
  # @example Allowing up to fifteen requests in seven seconds.
  #   use Rack::Throttle::Burst, :sliding_time_window => 7, :max_per_window => 15, :banned_secs => 90
  #
  class Burst < Limiter

    SLIDING_TIME_WINDOW = 5
    MAX_PER_WINDOW = 10
    BANNED_SECS = 60

    DEFAULTS = {
      :sliding_time_window => SLIDING_TIME_WINDOW, 
      :max_per_window => MAX_PER_WINDOW, 
      :banned_secs => BANNED_SECS,
      :logger => NullLoger.new,
      :throttle => :on
    }

    ##
    # @param  [#call]                  app
    # @param  [Hash{Symbol => Object}] options
    # @option options [Integer] :sliding_time_window  (5)
    # @option options [Integer] :max_per_window       (10)
    # @option options [Integer] :banned_secs          (60)
    # @option options [Symbol] :throttle              (:on)
    def initialize(app, options = {})
      options = DEFAULTS.merge(options)
      super
      logger.debug "[Rack::Throttle::Burst] init_options: #{options.map{|k,v| "#{k}=#{v}"}.join(',')}"
    end

    ##
    # Returns `true` if whitelisted or client has less than
    # configured amount of requests made for the sliding window of time.
    # If client has exceeded the limit, he will be disallowed for
    # configured amount of time.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def allowed?(request)
      count = 0
      allowed = true
      begin
        return true if whitelisted?(request)
        ts = Time.now.to_i
        client_data = cache_get(key = cache_key(request))
        if client_data
          client_data = Oj.load(client_data)
          if client_data["banned"]
            secs_banned = ts - client_data["banned_at"]
            if secs_banned >= @options[:banned_secs]
              client_data = {"banned" => false, "calls" => {ts => 1}}
              logger.info "[Rack::Throttle::Burst] cancel_banned: client_identifier=#{key}, after: #{secs_banned}s"
            else
              allowed = false
              logger.info "[Rack::Throttle::Burst] still_banned: client_identifier=#{key}, banned: #{secs_banned}s"
            end
          else
            if client_data["calls"]
              client_data["calls"].delete_if{ |timestamp,call_count| timestamp.to_i < (ts - @options[:sliding_time_window]) }
              client_data["calls"].has_key?(ts.to_s) ? client_data["calls"][ts.to_s] += 1 : client_data["calls"][ts.to_s] = 1
            else
              client_data = {"banned" => false, "calls" => {ts.to_s => 1}}
            end
            count = client_data["calls"].values.inject{|sum,x| sum + x } 
            allowed = count <= @options[:max_per_window]
            unless allowed
              client_data = {"banned" => true, "banned_at" => ts}
              logger.info "[Rack::Throttle::Burst] rate_limit_exceeded: client_identifier=#{key}, hit_rate: #{count}, user_agent: #{request.env["HTTP_USER_AGENT"]}, path_info: #{request.env["PATH_INFO"]}, script_uri: #{request.env["SCRIPT_URI"]}"
            end
          end
        else
          client_data = {"banned" => false, "calls" => {ts.to_s => 1}}
        end

        cache_set(key, Oj.dump(client_data))

        throttling? ? allowed : true
      rescue => e
        logger.info "Exception:#{client_data.inspect};#{e.backtrace}" rescue nil
        # If an error occurred while trying to update the timestamp stored
        # in the cache, we will fall back to allowing the request through.
        # This prevents the Rack application blowing up merely due to a
        # backend cache server (Memcached, Redis, etc.) being offline.
        allowed = true
      end
    end

    def logger
      @options[:logger]
    end

    def throttling?
      @options[:throttle] == :on
    end

  end
end; end
