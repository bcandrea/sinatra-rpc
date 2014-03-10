require 'spec_helper'
require 'sinatra/base'

describe Sinatra::RPC do

  module RpcTest

    class MyHandler
      # A greeting method.
      # @param people [String] the people to greet
      # @return [String] the greeting
      def hello(people)
        raise Sinatra::RPC::NoPeopleFault, "No people!" if people.nil? or people.empty?
        "Hello, #{people}!"
      end
    end

    class MyApp < Sinatra::Base
      register Sinatra::RPC
      register_rpc_fault :no_people, 211
      add_rpc_handler MyHandler

      post '/RPC2' do
        handle_rpc request
      end
    end
  end

  def app
    RpcTest::MyApp
  end

  # This method calls the RPC endpoint.
  def call(method, *params)
    request('/RPC2',
            :method => 'post',
            :params => XMLRPC::Marshal.dump_call(method, *params)
            )
  end

  # Unmarshals the response coming from the RPC endpoint.
  def parse(response)
    XMLRPC::Marshal.load_response(response.body)
  end

  it 'should have a version number' do
    Sinatra::RPC::VERSION.should_not be_nil
  end

  context 'using XMLRPC' do

    it 'should reply to RPC requests' do
      call('system.listMethods')
      #puts last_response.body
      last_response.should be_ok
    end

    it 'should return a 404 error if the method does not exist' do
      call('fake.method', 'an argument')
      last_response.status.should == 404
    end

    context 'with introspection' do

      it 'should list RPC methods' do
        call('system.listMethods')
        last_response.should be_ok
        parse(last_response).should == %w{
          hello
          system.listMethods
          system.methodHelp
          system.methodSignature
        }
      end

      it 'should show the method help' do
        call('system.methodHelp', 'hello')
        last_response.should be_ok
        parse(last_response).should == %q{
A greeting method.
@param people [String] the people to greet
@return [String] the greeting
}.strip
      end

      it 'should show method signatures' do
        call('system.methodSignature', 'hello')
        last_response.should be_ok
        parse(last_response).should == [['string', 'string']]
      end
    end

    context 'with a custom handler' do
      it 'should handle RPC requests' do
        call('hello', 'World')
        last_response.should be_ok
        parse(last_response).should == 'Hello, World!'
      end

      it 'should handle RPC faults' do
        call('hello', '')
        err = parse(last_response)
        err.faultCode.should == 211
      end
    end
  end

end
