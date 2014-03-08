require 'spec_helper'

describe Sinatra::RPC::Transport::Base do
  it 'should allow registering new classes' do
    class B64Transport < Sinatra::RPC::Transport::Base
      content_types 'text/base64'
    end

    Sinatra::RPC::Transport.find('text/base64').should == B64Transport
  end

  it 'should allow registering more than 1 content type' do
    class MultiTransport < Sinatra::RPC::Transport::Base
      content_types 'application/x-app1', 'application/x-app2'
    end

    Sinatra::RPC::Transport.find('application/x-app1').should == MultiTransport
    Sinatra::RPC::Transport.find('application/x-app2').should == MultiTransport
  end

end