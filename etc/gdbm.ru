$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/throttle'
require 'gdbm'

use Rack::Throttle::Interval, :min => 3.0, :cache => GDBM.new('/tmp/throttle.db')

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
