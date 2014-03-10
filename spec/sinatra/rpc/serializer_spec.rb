require 'spec_helper'

describe Sinatra::RPC::Serializer do

  before(:all) do
    @registry = Sinatra::RPC::Serializer.instance_variable_get('@registry').dup
  end

  after(:all) do
    Sinatra::RPC::Serializer.instance_variable_set('@registry', @registry)
  end

  it 'should allow registering new classes' do
    class B64Serializer < Sinatra::RPC::Serializer::Base
      content_types 'text/base64'
    end

    Sinatra::RPC::Serializer.find('text/base64').should == B64Serializer
  end

  it 'should allow registering more than 1 content type' do
    class MultiSerializer < Sinatra::RPC::Serializer::Base
      content_types 'application/x-app1', 'application/x-app2'
    end

    Sinatra::RPC::Serializer.find('application/x-app1').should == MultiSerializer
    Sinatra::RPC::Serializer.find('application/x-app2').should == MultiSerializer
  end

  it 'should allow registering a default Serializer' do
    class DefaultSerializer < Sinatra::RPC::Serializer::Base
      content_types nil, 'application/x-default'
    end

    Sinatra::RPC::Serializer.find('application/x-default').should == DefaultSerializer
    Sinatra::RPC::Serializer.find(nil).should == DefaultSerializer
  end

  it 'should select the default Serializer when an unsupported content type is specified' do
    class DefaultSerializer < Sinatra::RPC::Serializer::Base
      content_types nil, 'application/x-default'
    end

    Sinatra::RPC::Serializer.find('application/x-unsupported').should == DefaultSerializer
  end

end