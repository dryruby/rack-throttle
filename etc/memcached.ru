$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/throttle'
gem 'memcached'
require 'memcached'

use Rack::Throttle::Interval, :min => 3.0, :cache => Memcached.new

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
