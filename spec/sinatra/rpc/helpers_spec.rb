require 'spec_helper'

module HelpersTest
  class Serializer1 < Sinatra::RPC::Serializer::Base
    content_types 'application/x-app1', 'application/x-app2'
  end

  class Serializer2 < Sinatra::RPC::Serializer::Base
    content_types nil, 'application/x-app3'
  end

  class MyClass
    def my_method(text)
      "this is #{text}"
    end
  end

  class MyApp
    include Sinatra::RPC::Helpers
  end
end

describe Sinatra::RPC::Helpers do

  before(:each) do
    @app = HelpersTest::MyApp.new
  end

  context '#select_serializer' do
    it 'should generate the correct serializer instance' do
      @app.select_serializer(nil).class.should == HelpersTest::Serializer2
      @app.select_serializer('application/x-app2').class.should == HelpersTest::Serializer1
    end
  end

  context '#call_rpc_method' do

    before(:each) do
      @app = HelpersTest::MyApp.new
      @handler = HelpersTest::MyClass.new
      @app.class.stub(:get) do
        {'myClass.myMethod' =>
          {
            method: :my_method,
            handler: @handler,
            help: '',
            signature: [['string', 'string']]
          }
        }
      end
    end

    it 'should call the correct method' do
      @app.call_rpc_method('myClass.myMethod', 'some text').should == 'this is some text'
    end

    it 'should raise a NotFound exception if the method does not exist' do
      expect { 
        @app.call_rpc_method 'myClass.someMethod', [42] 
      }.to raise_error(Sinatra::RPC::NotFound)

      expect { 
        @app.call_rpc_method 'anotherMethod', ['arg1', 'arg2'] 
      }.to raise_error(Sinatra::RPC::NotFound)
    end
  end

  context '#handle_rpc' do
    before(:each) do
      @app = HelpersTest::MyApp.new
      @serializer = double('serializer', 
        parse: ['myClass.myMethod', ['some text']],
        dump: '<the serialized object>',
        content_type: 'test/content-type',
        content_type_options: {})
      @request_body = double('body', read: '<serialized request>')
      @request = double('request', body: @request_body, env: {})
      @app.stub(:content_type)
      @app.stub(:select_serializer) {@serializer}
      @app.stub(:call_rpc_method) { 'this is some text' }
      @app.stub(:halt)
    end

    it 'should handle a successful RPC call' do
      @app.handle_rpc(@request).should == '<the serialized object>'
    end
    
    it 'should reject empty requests with a 400 error' do
      @request_body.stub(:read) {''}
      @app.should_receive(:halt).with(400).once
      @app.handle_rpc(@request)
    end

    it 'should reply with a 404 when the method does not exist' do
      @app.should_receive(:call_rpc_method).
        with('myClass.myMethod', ['some text']).ordered.once.
        and_raise(Sinatra::RPC::NotFound)
      @app.should_receive(:halt).with(404).ordered.once
      @app.handle_rpc(@request)
    end

    context 'with errors' do

      before(:each) do
        @serializer.stub(:dump) do |ex|
          ex.message
        end
      end

      it 'should transmit back an RPC fault' do
        Sinatra::RPC::Fault.register(:this_is_a_test, 1234)
        ex = Sinatra::RPC::ThisIsATestFault.new 'Problems!'
        @app.should_receive(:call_rpc_method).
          with('myClass.myMethod', ['some text']).ordered.once.and_raise(ex)
        @serializer.should_receive(:dump).with(ex).ordered.once
        @app.handle_rpc(@request).should == 'Problems!'
      end

      it 'should wrap argument errors' do

        @app.should_receive(:call_rpc_method).
          with('myClass.myMethod', ['some text']).ordered.once.
          and_raise(ArgumentError.new('bad argument'))
        @serializer.should_receive(:dump).with(
          kind_of(Sinatra::RPC::BadRequestFault)).ordered.once
        @app.handle_rpc(@request).should == 'bad argument'
      end

      it 'should wrap generic errors' do
        @app.should_receive(:call_rpc_method).
          with('myClass.myMethod', ['some text']).ordered.once.
          and_raise(RuntimeError.new('a runtime error'))
        @serializer.should_receive(:dump).with(
          kind_of(Sinatra::RPC::GenericFault)).ordered.once
        @app.handle_rpc(@request).should == "RuntimeError: a runtime error"
      end
    end
  end

end