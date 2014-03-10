require 'spec_helper'

describe Sinatra::RPC::Serializer::Base do
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



end