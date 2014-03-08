require 'spec_helper'

describe Sinatra::RPC do
  it 'should have a version number' do
    Sinatra::RPC::VERSION.should_not be_nil
  end

  it 'should do something useful'
end
