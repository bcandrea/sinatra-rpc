require 'spec_helper'

describe Sinatra::RPC::Fault do
  it 'should generate exception classes' do
    Sinatra::RPC::Fault.register :bad_request, 400
    Sinatra::RPC::BadRequestFault::CODE.should == 400
    RuntimeError.should === Sinatra::RPC::BadRequestFault.new
    Sinatra::RPC::Fault.should === Sinatra::RPC::BadRequestFault.new
  end
end