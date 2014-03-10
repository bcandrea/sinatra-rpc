[![Build Status](https://travis-ci.org/bcandrea/sinatra-rpc.png?branch=master)](https://travis-ci.org/bcandrea/sinatra-rpc)
[![Coverage Status](https://coveralls.io/repos/bcandrea/sinatra-rpc/badge.png)](https://coveralls.io/r/bcandrea/sinatra-rpc)
[![Gem Version](https://badge.fury.io/rb/sinatra-rpc.png)](http://badge.fury.io/rb/sinatra-rpc)
[![Dependency Status](https://gemnasium.com/bcandrea/sinatra-rpc.png)](https://gemnasium.com/bcandrea/sinatra-rpc)

# Sinatra::Rpc

A simple [Sinatra extension module](http://www.sinatrarb.com/extensions.html) providing the functionality of an 
[RPC server](http://wikipedia.org/wiki/Remote_procedure_call).

This module allows exposure of all the public methods of any object via RPC. The only supported serialization 
method is [XML-RPC](http://wikipedia.org/wiki/XML-RPC) at the moment.

The full API documentation is available [here](http://rubydoc.info/github/bcandrea/sinatra-rpc/master/frames).

## Installation

Add this line to your application's Gemfile:

    gem 'sinatra-rpc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-rpc

## Usage

### Minimal example

The most basic example involves the definition of a _handler_ class first:

```ruby
class MyHandler
  # A greeting method.
  # @param people [String] the people to greet
  # @return [String] the greeting
  def hello(people)
    "Hello, #{people}!"
  end
end
```

The class does not need to include any module or implement a specific API; however, its methods need to be 
properly documented (following the [YARD](http://yardoc.org) conventions) to take advantage of the built-in 
introspection (more on that later).

Once the handler is defined, it can be added to a standard Sinatra application by registering the 
`Sinatra::RPC` extension.

```ruby
require 'spec_helper'
require 'sinatra/base'

class MyApp < Sinatra::Base
  register Sinatra::RPC
  add_rpc_handler MyHandler

  post '/RPC2' do
    handle_rpc request
  end
end
```

This application class will respond to XMLRPC POST requests sent to the '/RPC2' path. It can be easily tested
with the Ruby [built-in XMLRPC client](http://www.ruby-doc.org/stdlib/libdoc/xmlrpc/rdoc/XMLRPC/Client.html):

```ruby
require 'xmlrpc/client'
cli = XMLRPC::Client.new_from_uri 'http://myserver/RPC2'
cli.http_header_extra = {"accept-encoding" => "identity"}
cli.call 'hello', 'World'  # => this call should return 'Hello, World!'
```

(the extra header is needed because of a bug in Ruby 2.0.0 and 2.1.0, see https://bugs.ruby-lang.org/issues/8182).

### Namespacing and multiple handlers

Of course multiple objects can be registered as handlers. The `add_rpc_handler` method takes an optional 
namespace parameter that can be used to group and organize them.

```ruby
require 'spec_helper'
require 'sinatra/base'

class MyApp < Sinatra::Base
  register Sinatra::RPC
  add_rpc_handler MyHandler
  add_rpc_handler 'customHandler', CustomHandlerClass.new(:some_argument)

  post '/RPC2' do
    handle_rpc request
  end
end
```

As you can see, handler instances can be passed as well as classes. 

### Echo server and introspection

The RPC server implements the commonly adopted introspection interface for XML-RPC: the `system.listMethods`, 
`system.methodHelp` and `system.methodSignature` methods are automatically available. The metadata is only extracted
from the YARD-style comments in the handler classes, so expect inaccurate results if the code is not completely
documented.

Another facility is a simple `test.echo` method, which just return the passed argument.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
