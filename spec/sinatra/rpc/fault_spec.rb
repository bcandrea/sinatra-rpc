require 'spec_helper'

describe Sinatra::RPC::Fault do
  it 'should generate exception classes' do
    Sinatra::RPC::Fault.register :very_bad_request, 400
    Sinatra::RPC::VeryBadRequestFault::CODE.should == 400
    RuntimeError.should === Sinatra::RPC::VeryBadRequestFault.new
    Sinatra::RPC::Fault.should === Sinatra::RPC::VeryBadRequestFault.new
  end
end