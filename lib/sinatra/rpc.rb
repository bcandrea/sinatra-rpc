require "sinatra/rpc/version"
require "sinatra/rpc/helpers"
require "sinatra/rpc/fault"
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
  #       # Optional (this is the default value if none is set)
  #       # This parameter MUST be set before registering the extension
  #       set :rpc_path, '/RPC2'
  #       
  #       register Sinatra::RPC
  #       
  #       # Map custom error codes to Ruby exceptions
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
  #     end
  module RPC

    # The default value for the RPC path is '/RPC2'.
    DEFAULT_RPC_PATH = '/RPC2'

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
      unless rpc_method_index = get(:rpc_method_index)
        rpc_method_index = {}
        set(:rpc_method_index, rpc_method_index)
      end
      rpc_method_index.merge! Utils.rpc_methods namespace, handler
    end


    # A custom exception raised when a call is made to a non-existent handler or
    # method.
    class NotFound < RuntimeError; end

    # Callback executed when the app registers this extension module. Here we set
    # the default property values and register standard error codes and handlers.
    def self.registered(app)
      app.helpers Helpers

      # Register some generic fault codes (can be overridden)
      app.register_rpc_fault :generic, -1
      app.register_rpc_fault :bad_request, 100

      # Register the introspection handler class
      app.add_rpc_handler 'system', Handler::Introspection.new(app)

      # Get the right value of the RPC path
      rpc_path = (app.get(:rpc_path) or DEFAULT_RPC_PATH)
      
      # Handle all RPC POST requests.
      app.post rpc_path do

        # The request/response serializer can be XML-RPC (the default) 
        # or any serializer implemented as a subclass of Sinatra::RPC::Serializer::Base.
        # The serializer class is chosen by reading the 'Content-Type' header in the request.
        serializer = select_serializer(request.env['CONTENT_TYPE'])

        req = request.body.read

        # An empty request is not acceptable in RPC.
        if req.empty?
          halt 400
        end

        # Generate the response.
        resp = begin
          # Parse the contents of the request.
          method, arguments = serializer.parse req

          # Execute the method call.
          call_rpc_method(method, arguments)
        rescue Sinatra::RPC::NotFound
          halt 404
        rescue Sinatra::RPC::Fault => ex
          ex
        rescue ArgumentError => ex
          Sinatra::RPC::BadRequestFault.new(ex.message)
        rescue Exception => ex
          Sinatra::RPC::GenericFault.new("#{ex.class.name}: #{ex.message}")
        end
 
        content_type(serializer.content_type, serializer.content_type_options)
        serializer.dump(resp)

      end
    end
  end
end
