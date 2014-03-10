require 'sinatra/rpc/serializer/base'
require 'xmlrpc/marshal'

module Sinatra
  module RPC
    module Serializer
      # This class handles XML-RPC calls.
      class XMLRPC < Base
        content_types nil, 'text/xml'

        # This initializer creates an internal XMLRPC::Marshal instance.
        def initialize
          @xmlrpc = ::XMLRPC::Marshal.new
        end

        # The charset is set to UTF-8.
        # (see Base#content_type_options)
        def content_type_options
          {charset: 'utf-8'}
        end

        # (see Base#parse)
        def parse(request)
          @xmlrpc.load_call(request)
        end

        # (see Base#dump)
        def dump(response)
          if Sinatra::RPC::Fault === response 
            response = ::XMLRPC::FaultException.new(response.code, response.message)
          end
          @xmlrpc.dump_response(response)
        end
      end
    end
  end
end