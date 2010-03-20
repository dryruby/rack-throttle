module Rack module Throttle
  ##
  class Limiter
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
      # TODO
    end
  end
end end
