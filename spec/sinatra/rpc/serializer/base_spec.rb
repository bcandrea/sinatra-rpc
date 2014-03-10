require 'spec_helper'

describe Sinatra::RPC::Serializer::Base do

  before(:all) do
    @registry = Sinatra::RPC::Serializer.instance_variable_get('@registry').dup
  end

  after(:all) do
    Sinatra::RPC::Serializer.instance_variable_set('@registry', @registry)
  end

  it 'should set the correct response content type' do
    class B64Serializer < Sinatra::RPC::Serializer::Base
      content_types 'text/base64'
    end

    B64Serializer.new.content_type.should == 'text/base64'
  end

  it 'should set the response content type of the default serializer' do
    class DefaultSerializer < Sinatra::RPC::Serializer::Base
      content_types nil, 'application/x-default'
    end

    class AnotherDefaultSerializer < Sinatra::RPC::Serializer::Base
      content_types 'application/x-another-default', nil
    end

    DefaultSerializer.new.content_type.should == 'application/x-default'
    AnotherDefaultSerializer.new.content_type.should == 'application/x-another-default'
  end

  it 'should set default content type options' do
    class OptionsSerializer < Sinatra::RPC::Serializer::Base
      content_types 'application/x-opt'
    end
    OptionsSerializer.new.content_type_options.should == {}
  end

  it 'should raise an exception if the dump or parse methods are not implemented' do
    class DummySerializer < Sinatra::RPC::Serializer::Base
      content_types 'application/x-no-parse'
    end

    expect { DummySerializer.new.dump(Object.new) }.to raise_error(NotImplementedError)
    expect { DummySerializer.new.parse("request") }.to raise_error(NotImplementedError)
  end

end