require "rack/test"
require 'timecop'
require "rack/throttle"
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

#RSpec.configure do |config|
#end
