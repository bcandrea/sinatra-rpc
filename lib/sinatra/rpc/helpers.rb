require 'sinatra/rpc/serializer'
module Sinatra
  module RPC
    # Some methods to include in the app class.
    module Helpers
      
      # Generate a serializer instance suitable for the incoming RPC request.
      # (see Sinatra::RPC::Serializer.find)
      def select_serializer(content_type)
        Sinatra::RPC::Serializer.find(content_type).new
      end

      # Execute an RPC method with the given name and arguments.
      #
      # @param method [String] the RPC method name, e.g. 'system.listMethods'
      # @param arguments [Array] the list of arguments
      # @return [Object] the return value of the method call on the target handler
      def call_rpc_method(method, arguments)
        m = settings.rpc_method_index[method]
        raise Sinatra::RPC::NotFound if m.nil?
        m[:handler].send m[:method], *arguments
      end

      # Handle RPC requests. This method should be called inside a POST definition.
      # @param request the incoming HTTP request object
      # @example
      #     class MyApp < Sinatra:Base
      #       register Sinatra::RPC
      #       add_rpc_handler MyHandlerClass
      #
      #       post '/RPC2' do
      #         handle_rpc(request)
      #       end
      #     end
      def handle_rpc(request)
        # The request/response serializer can be XML-RPC (the default) 
        # or any serializer implemented as a subclass of Sinatra::RPC::Serializer::Base.
        # The serializer class is chosen by reading the 'Content-Type' header in the request.
        serializer = select_serializer(request.env['CONTENT_TYPE'])
        
        body = request.body.read

        # An empty request is not acceptable in RPC.
        if body.empty?
          halt 400
        end

        # Generate the response.
        resp = begin
          # Parse the contents of the request.
          method, arguments = serializer.parse body

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