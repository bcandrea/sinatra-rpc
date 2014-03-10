require 'spec_helper'

describe Sinatra::RPC::Handler::Introspection do

  before(:each) do
    index = {
      'ns.myMethod' => {
        handler:   nil,
        method:    :my_method, 
        help:      "This is a test method.",
        signature: [['nil']]
      },
      'ns.greet' => {
        handler:   nil,
        method:    :greet, 
        help:      %q{
Full method doc for greet.
@param folks [String] people to greet
@return [String] the greeting
}.strip,
        signature: [['string', 'string']]
      },
      'ns.bye' => {
        handler:   nil,
        method:    :bye, 
        help:      %q{
Partially documented.
@param people [String] the people
}.strip,
        signature: [['nil', 'string']]
      },
      'ns.soLong' => {
        handler:   nil,
        method:    :so_long, 
        help:      %q{
Partially documented.
@return [String] the result
}.strip,
        signature: [['string']]
      },
      'ns.multi' => {
        handler:   nil,
        method:    :multi, 
        help:      %q{
Multiple types.
@param arg [String, Class] the arg
@return [Array] the result
}.strip,
        signature: [['array', 'string']]
      },
    }
    @settings = double('settings', rpc_method_index: index)
    @app = double('app', settings: @settings)
    @intro = Sinatra::RPC::Handler::Introspection.new @app
  end

  it 'should list all the methods in the correct order' do
    @intro.list_methods.should == %w{ ns.bye ns.greet ns.multi ns.myMethod ns.soLong }
  end

  it 'should get the method signatures' do
    @intro.method_signature('ns.multi').should == [['array', 'string']]
    @intro.method_signature('ns.greet').should == [['string', 'string']]
  end

  it 'should get the method help' do
    @intro.method_help('ns.myMethod').should == "This is a test method."
    @intro.method_help('ns.soLong').should == %q{
Partially documented.
@return [String] the result
}.strip
  end

end