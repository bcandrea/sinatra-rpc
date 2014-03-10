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
    def self.get(key)
      if key == :rpc_method_index
        {'myClass.myMethod' =>
          {
            method: :my_method,
            handler: MyClass.new,
            help: '',
            signature: [['string', 'string']]
          }
        }
      end
    end
  end
end

describe Sinatra::RPC::Helpers do

  context '#select_serializer' do
    it 'should generate the correct serializer instance' do
      HelpersTest::MyApp.new.select_serializer(nil).class.should == HelpersTest::Serializer2
      HelpersTest::MyApp.new.select_serializer('application/x-app2').class.should == HelpersTest::Serializer1
    end
  end

  context '#call_rpc_method' do
    it 'should call the correct method' do
      HelpersTest::MyApp.new.call_rpc_method('myClass.myMethod', 'some text').should == 'this is some text'
    end

    it 'should raise a NotFound exception if the method does not exist' do
      expect { 
        HelpersTest::MyApp.new.call_rpc_method 'myClass.someMethod', [42] 
      }.to raise_error(Sinatra::RPC::NotFound)

      expect { 
        HelpersTest::MyApp.new.call_rpc_method 'anotherMethod', ['arg1', 'arg2'] 
      }.to raise_error(Sinatra::RPC::NotFound)
    end
  end

end