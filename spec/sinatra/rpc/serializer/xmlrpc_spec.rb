require 'spec_helper'

describe Sinatra::RPC::Serializer::XMLRPC do

  before(:each) do
    @xmlrpc = Sinatra::RPC::Serializer.find('text/xml').new
  end

  it 'should parse requests correctly' do
    req = XMLRPC::Marshal.dump_call('handler.myMethod', 'arg1', 42)
    @xmlrpc.parse(req).should == ['handler.myMethod', ['arg1', 42]]
    req = XMLRPC::Marshal.dump_call('simpleMethod', false, 1, 2, 'string')
    @xmlrpc.parse(req).should == ['simpleMethod', [false, 1, 2, 'string']]
  end

  it 'should dump responses correctly' do
    XMLRPC::Marshal.load_response(@xmlrpc.dump('result')).should == 'result'
    XMLRPC::Marshal.load_response(@xmlrpc.dump([1, 'array'])).should == [1, 'array']
  end
end