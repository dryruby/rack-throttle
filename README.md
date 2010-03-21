HTTP Request Rate Limiter for Rack
==================================

This is [Rack][] middleware that provides logic for rate-limiting incoming
HTTP requests to your Rack application. You can use `Rack::Throttle` with
any Ruby web framework based on Rack, including with Ruby on Rails 3.0 and
with Sinatra.

* <http://github.com/datagraph/rack-throttle>

Examples
--------

### Adding throttling to a Rackup application

    require 'rack/throttle'

    use Rack::Throttle::Interval

    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }

### Enforcing a 3-second interval between requests

    use Rack::Throttle::Interval, :min => 3.0

### Using Memcached to store rate-limiting counters

    use Rack::Throttle::Interval, :cache => Memcached.new, :key_prefix => :throttle

Documentation
-------------

<http://datagraph.rubyforge.org/rack-throttle/>

* {Rack::Throttle}
  * {Rack::Throttle::Interval}
  * {Rack::Throttle::Daily}
  * {Rack::Throttle::Hourly}

Dependencies
------------

* [Rack](http://rubygems.org/gems/rack) (>= 1.0.0)

Installation
------------

The recommended installation method is via RubyGems. To install the latest
official release, do:

    % [sudo] gem install rack-throttle

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/datagraph/rack-throttle.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/datagraph/rack-throttle/tarball/master

Author
------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

`Rack::Throttle` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[Rack]: http://rack.rubyforge.org/
