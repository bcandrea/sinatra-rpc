require "sinatra/rpc/utils"
module Sinatra
  module RPC

    # This module is used to generate all custom RPC errors.
    module Fault
      # Generate a new fault class. The class will be a subclass of RuntimeError,
      # and always include the Fault module.
      #
      # @param fault_name [String, Symbol] An identifier for the fault; if
      #   the name is e.g. 'bad_request', a new class named BadRequestFault
      #   is generated
      # @param error_code [Integer] A unique numeric code for this fault
      # @example
      #     Sinatra::RPC::Fault.register :bad_request, 400
      #     Sinatra::RPC::BadRequestFault::CODE                       # => 400
      #     raise Sinatra::RPC::BadRequestFault, "Bad request"
      #     RuntimeError === Sinatra::RPC::BadRequestFault.new        # => true
      #     Sinatra::RPC::Fault === Sinatra::RPC::BadRequestFault.new # => true
      def self.register(fault_name, error_code)
        fault_class = Class.new(RuntimeError) do
          include Sinatra::RPC::Fault
          def code
            self.class.const_get 'CODE'
          end
        end
      
        fault_class.const_set 'CODE', error_code

        class_name = "#{Sinatra::RPC::Utils.camelize fault_name}Fault"
        Sinatra::RPC.const_set(class_name, fault_class)
      end
    end
  end
end