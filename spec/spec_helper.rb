require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/test'
require 'sinatra/rpc'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
