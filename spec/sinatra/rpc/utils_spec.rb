require 'spec_helper'

class MyClass
  # This is a test method.
  def my_method; end

  # Full method doc for greet.
  # @param folks [String] people to greet
  # @return [String] the greeting
  def greet(folks); "Hi, #{folks}!"; end

  # Partially documented.
  # @param people [String] the people
  def bye(people); "Bye, #{people}!"; end

  # Partially documented.
  # @return [String] the result
  def so_long(people); "So long, #{people}!"; end

  # Multiple types.
  # @param arg [String, Class] the arg
  # @return [Array] the result
  def multi(arg); ["The argument is #{arg}!"]; end  
end

class SimpleClass
  # This is a test method.
  def my_method; end
end

def m(name)
  MyClass.instance_method name
end

describe Sinatra::RPC::Utils do
  context '.camelize' do
    it 'should convert underscored strings' do
      Sinatra::RPC::Utils.camelize('my_test_string').should == 'MyTestString'
      Sinatra::RPC::Utils.camelize('_starts_with_underscore').should == 'StartsWithUnderscore'
      Sinatra::RPC::Utils.camelize('ends_with_underscore_').should == 'EndsWithUnderscore'
    end

    it 'should generate strings starting with a lowercase letter' do
      Sinatra::RPC::Utils.camelize('my_test_string', false).should == 'myTestString'
    end

    it 'should convert symbols' do
      Sinatra::RPC::Utils.camelize(:my_test_sym, false).should == 'myTestSym'
    end
  end

  context '.underscore' do
    it 'should convert camelcase strings' do
      Sinatra::RPC::Utils.underscore('MyTestString').should == 'my_test_string'
    end

    it 'should convert string starting with a lowercase letter' do
      Sinatra::RPC::Utils.underscore('myTestString').should == 'my_test_string'
    end
  end

  context '.method_help' do
    it 'should generate a simple help string' do
      doc = "This is a test method."
      Sinatra::RPC::Utils.method_help(m(:my_method)).should == doc
    end

    it 'should include tags in the help string' do
      doc = %q{
Full method doc for greet.
@param folks [String] people to greet
@return [String] the greeting
}.strip
      Sinatra::RPC::Utils.method_help(m(:greet)).should == doc
    end
  end

  context '.method_signature' do
    it 'should extract a valid signature from the documentation' do
      Sinatra::RPC::Utils.method_signature(m(:greet)).should == [['string', 'string']]
    end

    it 'should return an empty string if the signature is invalid' do
      Sinatra::RPC::Utils.method_signature(m(:my_method)).should == [['nil']]
    end

    it 'should handle partially documented methods' do
      Sinatra::RPC::Utils.method_signature(m(:bye)).should == [['nil', 'string']]
      Sinatra::RPC::Utils.method_signature(m(:so_long)).should == [['string']]
    end

    it 'should handle multiple argument types' do
      Sinatra::RPC::Utils.method_signature(m(:multi)).should == [['array', 'string']]
    end
  end

  context '.rpc_methods' do
    it 'should correctly generate the RPC method index' do
      c = MyClass.new
      index = {
        'ns.myMethod' => {
          handler:   c, 
          method:    :my_method, 
          help:      "This is a test method.",
          signature: [['nil']]
        },
        'ns.greet' => {
          handler:   c, 
          method:    :greet, 
          help:      %q{
Full method doc for greet.
@param folks [String] people to greet
@return [String] the greeting
}.strip,
          signature: [['string', 'string']]
        },
        'ns.bye' => {
          handler:   c, 
          method:    :bye, 
          help:      %q{
Partially documented.
@param people [String] the people
}.strip,
          signature: [['nil', 'string']]
        },
        'ns.soLong' => {
          handler:   c, 
          method:    :so_long, 
          help:      %q{
Partially documented.
@return [String] the result
}.strip,
          signature: [['string']]
        },
        'ns.multi' => {
          handler:   c, 
          method:    :multi, 
          help:      %q{
Multiple types.
@param arg [String, Class] the arg
@return [Array] the result
}.strip,
          signature: [['array', 'string']]
        },
      }
      Sinatra::RPC::Utils.rpc_methods('ns', c).should == index
    end

    it 'should work without specifying a namespace' do
      c = SimpleClass.new
      index = {
        'myMethod' => {
          handler:   c, 
          method:    :my_method, 
          help:      "This is a test method.",
          signature: [['nil']]
        }
      }
      Sinatra::RPC::Utils.rpc_methods(c).should == index
    end
  end
end
