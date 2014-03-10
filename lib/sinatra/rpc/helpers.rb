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
        m = self.class.get(:rpc_method_index)[method]
        raise Sinatra::RPC::NotFound if m.nil?
        m[:handler].send m[:method], *arguments
      end
    end
  end
end