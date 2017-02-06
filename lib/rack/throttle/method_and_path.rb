module Rack
  module Throttle
    class MethodAndPath < TimeWindow
      ##
      # @param  [#call]                  app
      # @param  [Hash{Symbol => Object}] options
      # @option options [Integer] :max   (1)
      def initialize(app, options = {})
        super
      end

      def limits
        @limits ||= options[:limits]
      end

      def path_limit(request)
        limits["paths"].find { |k,v| 
          request.path.match(k)
        }
      end
      
      def method_limit(request)
        limits["methods"].find { |k,v| 
          request.request_method.match(k)
        }
      end

      def max_per_window(request)
        limit = path_limit(request) || method_limit(request)
        limit ? limit[1] : limits["default"]
      end

      def client_identifier(request)
        if path_limit(request)
          "#{request.ip.to_s}_#{request.path}"
        elsif method_limit(request)
          "#{request.ip.to_s}_#{request.request_method}"
        else
          request.ip.to_s
        end
      end

      def cache_key(request)
        [super, Time.now.strftime(time_string)].join(':')
      end

      def time_string
        @time_string ||= case options[:time_window]
          when :second then '%Y-%m-%dT%H:%M:%S'
          when :minute then '%Y-%m-%dT%H:%M'
          when :hour   then '%Y-%m-%dT%H'
          when :day    then '%Y-%m-%d'
          else              '%Y-%m-%dT%H:%M:%S'
        end
      end
    end
  end
end

