require 'method_source'
module Sinatra
  module RPC
    module Utils
      # Returns the camelcase version of the given string.
      # 
      # @param string [String] the string to convert
      # @param uppercase_first_letter [Boolean] set to true if the first letter of the 
      #   result needs to be uppercase
      # @return [String] the converted string
      # @example
      #
      #     Sinatra::RPC::Utils.camelize 'my_test_method', false  # => 'myTestMethod'
      #     Sinatra::RPC::Utils.camelize 'test_class'             # => 'TestClass'
      #
      def camelize(string, uppercase_first_letter = true)
        tokens = string.to_s.split /_+/
        first_token = (uppercase_first_letter ? tokens.first.capitalize : tokens.first.downcase)
        ([first_token] + tokens[1..-1].map(&:capitalize)).join
      end

      # Converts a camelcase string to its underscore version.
      #
      # @param string [String] the string to convert
      # @return [String] the converted string
      def underscore(string)
        word = string.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

      # Extract the documentation for a given object method.
      #
      # @param method [Method] a method object
      # @return [String] the method help, without initial comment characters (#)
      def method_help(method)
        method.comment.gsub(/^#\s/m, '').strip
      end

      # Extract the signature for a given object method, as a list of string starting
      # with the return type. The information is retrieved only by parsing the documentation,
      # and the value [['nil']] is returned if no documentation is available.
      #
      # @param method [Method] a method object
      # @return [String] the method signature as a list of strings
      def method_signature(method)
        help = method_help(method)
        params = []
        ret = nil
        help.each_line do |l|
          case l 
          when /@param[\s\w]+\[(\w+).*\]/
            params << $1.downcase
          when /@return[\s\w]+\[(\w+).*\]/
            ret = $1.downcase
          end
        end
        ret ||= 'nil'
        [[ret] + params]
      end

      # Return a hash with all the methods in an object that can be exposed as
      # RPC methods as keys. The values are themselves hashes containing the 
      # object, the name of the Ruby method, a method description and its signature.
      #
      # @example
      #
      #     # A simple class.
      #     class MyClass
      #       # A simple method.
      #       # @param folks [String] people to greet
      #       # @return [String] the greeting
      #       def greet(folks); "hi, #{folks}!"; end
      #     end
      #
      #     Sinatra::RPC::Utils.rpc_methods 'myclass', MyClass.new
      #     # => {'myclass.myMethod' => {
      #     #      handler:   <MyClass instance>, 
      #     #      method:    :my_method, 
      #     #      help:      "A simple method.\n@param folks [String] ...",
      #     #      signature: [['string', 'string']]
      #     #    }
      def rpc_methods(namespace = nil, object)
        public_methods = object.class.instance_methods - Object.instance_methods
        method_index = {}
        public_methods.each do |method_name|
          method = object.class.instance_method(method_name)
          rpc_name = camelize method_name, false
          key = [namespace, rpc_name].compact.join '.'
          method_index[key] = {
            handler: object,
            method:  method_name,
            help: method_help(method),
            signature: method_signature(method)
          }
        end
        method_index
      end

      extend self
    end
  end
end
