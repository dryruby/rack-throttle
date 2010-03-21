HTTP Request Rate Limiter for Rack Applications
===============================================

This is [Rack][] middleware that provides logic for rate-limiting incoming
HTTP requests to Rack applications. You can use `Rack::Throttle` with any
Ruby web framework based on Rack, including with Ruby on Rails 3.0 and with
Sinatra.

* <http://github.com/datagraph/rack-throttle>

Features
--------

* Throttles a Rack application by enforcing a minimum interval (by default,
  1 second) between subsequent HTTP requests from a particular client.
* Compatible with any Rack application and any Rack-based framework.
* Stores rate-limiting counters in any key/value store implementation that
  responds to `#[]`/`#[]=` (like Ruby's hashes) or to `#get`/`#set` (like
  memcached or Redis).
* Compatible with the [gdbm][] binding included in Ruby's standard library.
* Compatible with the [memcached][], [memcache-client][], [memcache][] and
  [redis][] gems.
* Compatible with [Heroku][]'s [memcached add-on][Heroku memcache]
  (currently available as a free beta service).

Examples
--------

### Adding throttling to a Rackup application

    require 'rack/throttle'

    use Rack::Throttle::Interval

    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }

### Enforcing a 3-second interval between requests

    use Rack::Throttle::Interval, :min => 3.0

### Using GDBM to store rate-limiting counters

    require 'gdbm'
    use Rack::Throttle::Interval, :cache => GDBM.new('tmp/throttle.db')

### Using Memcached to store rate-limiting counters

    require 'memcached'
    use Rack::Throttle::Interval, :cache => Memcached.new, :key_prefix => :throttle

### Using Redis to store rate-limiting counters

    require 'redis'
    use Rack::Throttle::Interval, :cache => Redis.new, :key_prefix => :throttle

HTTP Client Identification
--------------------------

The rate-limiting counters stored and maintained by `Rack::Throttle` are
keyed to unique HTTP clients.

By default, HTTP clients are uniquely identified by their IP address as
returned by `Rack::Request#ip`. If you wish to instead use a more granular,
application-specific identifier such as a session key or a user account
name, you need only subclass `Rack::Throttle::Interval` and override the
`#client_identifier` method.

HTTP Response Codes and Headers
-------------------------------

### 403 Forbidden (Rate Limit Exceeded)

When a client exceeds their rate limit, `Rack::Throttle` by default returns
a "403 Forbidden" response with an associated "Rate Limit Exceeded" message
in the response body.

An HTTP 403 response means that the server understood the request, but is
refusing to respond to it and an accompanying message will explain why.
This indicates an error on the client's part in exceeding the rate limits
outlined in the acceptable use policy for the site, service, or API.

### 503 Service Unavailable (Rate Limit Exceeded)

However, there is an unfortunately widespread practice of instead returning
a "503 Service Unavailable" response when a client exceeds the set rate
limits. This is actually technically incorrect because it indicates an
error on the server's part, which is certainly not the case with rate
limiting - it was the client that committed the oops, not the server.

An HTTP 503 response would be correct in situations where the server was
genuinely overloaded and couldn't handle more requests, but for rate
limiting an HTTP 403 response is more appropriate. Nonetheless, if you think
otherwise, `Rack::Throttle` does allow you to override the returned HTTP
status code by passing in a `:code => 503` option when constructing a
`Rack::Throttle::Limiter` instance.

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

[Rack]:            http://rack.rubyforge.org/
[gdbm]:            http://ruby-doc.org/stdlib/libdoc/gdbm/rdoc/classes/GDBM.html
[memcached]:       http://rubygems.org/gems/memcached
[memcache-client]: http://rubygems.org/gems/memcache-client
[memcache]:        http://rubygems.org/gems/memcache
[redis]:           http://rubygems.org/gems/redis
[Heroku]:          http://heroku.com/
[Heroku memcache]: http://docs.heroku.com/memcache
