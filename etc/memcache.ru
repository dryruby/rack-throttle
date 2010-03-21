$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/throttle'
gem 'memcache'
require 'memcache'

use Rack::Throttle::Interval, :min => 3.0, :cache => Memcache.new(:server => 'localhost:11211')

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
