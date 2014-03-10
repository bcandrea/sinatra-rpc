require 'sinatra/rpc/serializer/base'
require 'xmlrpc/marshal'

module Sinatra
  module RPC
    module Serializer
      # This class handles XML-RPC calls.
      class XMLRPC < Base
        content_types nil, 'text/xml'

        # The charset is set to UTF-8.
        # (see Base#content_type_options)
        def content_type_options
          {charset: 'utf-8'}
        end

        # (see Base#parse)
        def parse(request)
          XMLRPC::Marshal.load_call(xml)
        end

        # (see Base#dump)
        def dump(response)
          if Sinatra::RPC::Fault === response 
            response = XMLRPC::FaultException.new(response.code, response.message)
          end
          XMLRPC::Marshal.dump_response(response)
        end
      end
    end
  end
end