require "sinatra/rpc/version"
require "sinatra/rpc/helpers"
require "sinatra/rpc/fault"
require "sinatra/rpc/handler/echo"
require "sinatra/rpc/handler/introspection"

module Sinatra
  # This extension provides the functionality of an RPC server. 
  # The resulting server will handle all POST requests to /RPC2 and dispatch methods
  # to the underlying handler objects. For example, calling the 'myHandler.myMethod'
  # method will actually execute
  #
  #     my_handler.my_method
  #
  # on the target handler. RPC methods are usually camelcased, so an automatic 
  # conversion to and from standard method names with underscores is performed at registration.
  #
  # @example Application class
  #     require "sinatra/base"
  #     require "sinatra/rpc"
  #     
  #     class MyApp < Sinatra::Base   
  #       register Sinatra::RPC
  #       
  #       # Map custom error codes to Ruby exceptions: this will
  #       # generate a class named SomeErrorFault
  #       register_rpc_fault :some_error, 399
  #       
  #       # Add a new sub-handler in the 'myHandler' namespace
  #       add_rpc_handler 'myHandler', MyHandlerClass.new(1, 2, 3, 4)
  #       
  #       # The class name is enough if there is a no-arg constructor
  #       add_rpc_handler 'otherHandler', OtherHandler
  #       
  #       # If the handler namespace is omitted, all the methods are added directly 
  #       # to the server (empty) namespace
  #       add_rpc_handler MyDefaultRPCHandler
  #
  #       # Define the RPC endpoint (it must be a POST request)
  #       post '/RPC2' do
  #         handle_rpc(request)
  #       end
  #     end
  module RPC

    # (see Fault.register)
    # @example
    #     require "sinatra/base"
    #     require "sinatra/rpc"
    #         
    #     class MyApp < Sinatra::Base
    #       register Sinatra::RPC
    #       register_rpc_fault :some_error, 399
    #     end
    def register_rpc_fault(fault_name, error_code)
      Fault.register fault_name, error_code
    end

    # Add a new RPC handler object. If specified, the namespace is used as a
    # prefix for all the RPC method calls. All the public methods exposed by the 
    # handler object will be made available as RPC methods (with a camelcase name).
    #
    # @param namespace [String] the (optional) namespace for all the exposed methods
    # @param handler [Object, Class] a handler instance, or its class (if a no-arg 
    #   constructor is available)
    # @example
    #     require "sinatra/base"
    #     require "sinatra/rpc"
    #         
    #     class MyApp < Sinatra::Base
    #       register Sinatra::RPC
    #       add_rpc_handler 'list', MyListInterface
    #       add_rpc_handler BaseObject.new(some_status)
    #     end
    def add_rpc_handler(namespace = nil, handler)
      handler = handler.new if Class === handler
      settings.rpc_method_index.merge! Utils.rpc_methods namespace, handler
    end

    # A custom exception raised when a call is made to a non-existent handler or
    # method.
    class NotFound < RuntimeError; end

    # Callback executed when the app registers this extension module. Here we set
    # the default property values and register standard error codes and handlers.
    def self.registered(app)
      app.helpers Helpers

      # Initialize the method index
      app.set(:rpc_method_index, {})

      # Register the echo handler class
      app.add_rpc_handler 'test', Handler::Echo

      # Register the introspection handler class
      app.add_rpc_handler 'system', Handler::Introspection.new(app)
    end
  end
end
