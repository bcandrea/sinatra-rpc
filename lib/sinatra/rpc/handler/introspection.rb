module Sinatra
  module RPC
    module Handler
      # The instrospection handler can be used to display metadata about the
      # RPC server. It adds the `listMethods`, `methodSignature` and `methodHelp` RPC methods to 
      # the `system` namespace.
      class Introspection

        # The initializer requires a reference the current application.
        #
        # @param app [Sinatra::Base] the current Sinatra application
        def initialize(app)
          @app = app
        end

        # List the available methods.
        # @return [Array] the array of methods exposed by this RPC server.
        def list_methods
          index.keys.sort
        end
        
        # Return the signature of the given method.
        # @param method_name [String] the method name in the form `handler.methodName`.
        # @return [Array] a list of the form [return, param1, param2, ...].
        def method_signature(method_name)
          index[method_name][:signature]
        end
        
        # Return a help for the given method.
        # @param method_name [String] the method name in the form `handler.methodName`.
        # @return [String] a description of the method.
        def method_help(method_name)
          index[method_name][:help]
        end

        private

          def index
            @app.settings.rpc_method_index
          end
      end
    end
  end
end