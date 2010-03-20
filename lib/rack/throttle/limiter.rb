module Rack module Throttle
  ##
  # Rate limiter middleware for Rack.
  class Limiter
    attr_reader :app
    attr_reader :options

    ##
    # @param  [#call]                  app
    # @param  [Hash{Symbol => Object}] options
    def initialize(app, options = {})
      @app, @options = app, options
    end

    ##
    # @param  [Hash{String => String}] env
    # @return [Array(Integer, Hash, #each)]
    def call(env)
      if match?(request = Rack::Request.new(env))
        rate_limit_exceeded
      else
        app.call(env)
      end
    end

    ##
    # Returns `true` if the rate limit has been exceeded for the given
    # `request`.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def match?(request)
      case
        when blacklisted?(request) then true
        when whitelisted?(request) then false
        else false # TODO
      end
    end

    alias_method :match, :match?

    ##
    # Returns `true` if the originator of the given `request` is whitelisted
    # (not subject to further rate limits).
    #
    # The default implementation always returns `false`. Override this
    # method in a subclass to implement custom whitelisting logic.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    # @abstract
    def whitelisted?(request)
      false
    end

    ##
    # Returns `true` if the originator of the given `request` is blacklisted
    # (not honoring rate limits, and thus permanently forbidden access
    # without the need to maintain further rate limit counters).
    #
    # The default implementation always returns `false`. Override this
    # method in a subclass to implement custom blacklisting logic.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    # @abstract
    def blacklisted?(request)
      false
    end

    protected

    ##
    # Outputs a `Rate Limit Exceeded` error.
    #
    # @return [Array(Integer, Hash, #each)]
    def rate_limit_exceeded
      forbidden(options[:message] || 'Rate Limit Exceeded')
    end

    ##
    # Outputs an HTTP `403 Forbidden` response.
    #
    # @param  [String, #to_s] message
    # @return [Array(Integer, Hash, #each)]
    def forbidden(message = nil)
      http_error(403, message)
    end

    ##
    # Outputs an HTTP `4xx` or `5xx` response.
    #
    # @param  [Integer]       code
    # @param  [String, #to_s] message
    # @return [Array(Integer, Hash, #each)]
    def http_error(code, message = nil)
      [code, {'Content-Type' => 'text/plain; charset=utf-8'},
        http_status(code) + (message.nil? ? "\n" : " (#{message})\n")]
    end

    ##
    # Returns the standard HTTP status message for the given status `code`.
    #
    # @param  [Integer] code
    # @return [String]
    def http_status(code)
      [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ')
    end
  end
end end
