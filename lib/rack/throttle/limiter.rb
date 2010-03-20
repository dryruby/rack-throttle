module Rack module Throttle
  ##
  class Limiter
    attr_reader :app

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
      app.call(env) # TODO
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
    # Outputs an HTTP 4xx or 5xx response.
    #
    # @param  [Integer]       code
    # @param  [String, #to_s] message
    # @return [Array(Integer, Hash, #each)]
    def http_error(code, message = nil)
      [code, {'Content-Type' => 'text/plain; charset=utf-8'},
        http_status(code) + (message.nil? ? "\n" : " (#{message})\n")]
    end

    ##
    # Returns the HTTP status message for the given status `code`.
    #
    # @param  [Integer] code
    # @return [String]
    def http_status(code)
      [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ')
    end
  end
end end
