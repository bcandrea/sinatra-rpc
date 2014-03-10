module Sinatra
  module RPC
    # All the classes defined in this module represent serialization
    # mechanisms for RPC requests/responses.
    module Serializer

      # Find the right Serializer::Base subclass for the given 
      # Content-Type HTTP request header.
      #
      # @param content_type [String] the value of the Content-Type header
      # @return [Class] a Serializer class that can be used to
      #   satisfy the request
      def find(content_type)
        @registry[content_type] or @registry[nil]
      end

      # Add a serializer for a list of content types to the 
      # internal registry of Serializer classes.
      def register(serializer_class, content_types)
        @registry ||= {}
        content_types.each do |c|
          @registry[c] = serializer_class
        end
      end

      extend self
    end
  end
end

require "sinatra/rpc/serializer/xmlrpc"