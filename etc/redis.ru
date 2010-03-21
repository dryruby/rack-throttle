$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/throttle'
gem 'redis'
require 'redis'

use Rack::Throttle::Interval, :min => 3.0, :cache => Redis.new

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
