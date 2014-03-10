module Sinatra
  module RPC
    module Serializer
      # The base class for all Serializer instances.
      class Base

        class << self
          attr_reader :response_content_type
          
          # Set the list of content types supported by this serializer.
          # @param content_types [*String] the list of supported content types;
          #   if set to `nil`, this serializer is used as a default in case the
          #   content type is not specified in the request.
          def content_types(*content_types)
            Sinatra::RPC::Serializer.register self, content_types
            @response_content_type = content_types.compact.first
          end
        end

        # The content type that should be set in responses. By default
        # it is the first from the list of content types defined by the class.
        # @return [String] the content type to set in the response header.
        def content_type
          self.class.response_content_type
        end

        # An hash of options to set with the response content type.
        # For example, {charset: 'utf-8'} is used in XML-RPC.
        # The default implementation returns an empty hash.
        def content_type_options
          {}
        end

        # Parse an incoming RPC request. This method must be implemented by
        # subclasses.
        # @param request [String] the body of the HTTP POST request.
        # @return [Array] an array of the form ['handler.rpcMethod', [arg1, arg2, ...]] 
        def parse(request)
          raise NotImplementedError
        end

        # Convert the response object to a string to be used in the body of
        # the HTTP response. Must be implemented by subclasses.
        # @param response [Object] any response object
        # @return [String] a string representation of the response
        def dump(response)
          raise NotImplementedError
        end
      end
    end
  end
end