require 'spec_helper'

describe Sinatra::RPC::Handler::Echo do

  before(:each) do
    @echo = Sinatra::RPC::Handler::Echo.new
  end

  it 'returns the passed in argument' do
    @echo.echo("a string").should == "a string"
  end
end