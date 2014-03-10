module Sinatra
  module RPC
    module Handler
      # A simple test handler. Its only purpose is to provide a method that 
      # returns the passed string.
      class Echo

        # A simple echo method. It returns the passed string.
        # @param object [String] the string to return
        # @return [String] the string itself
        def echo(string)
          string
        end
      end
    end
  end
end