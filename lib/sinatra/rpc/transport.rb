module Sinatra
  module RPC
    module Transport
      # The registry of Transport classes.
      def registry
        @registry ||= {}
      end

      # Find the right Transport::Base subclass for the given 
      # Accept HTTP request header.
      #
      # @param accept_header [String] the value of the header
      # @return [Class] a Transport class that can be used to
      #   satisfy the request
      def find(accept_header)
        registry[accept_header]
      end

      extend self
    end
  end
end

require "sinatra/rpc/transport/xml"