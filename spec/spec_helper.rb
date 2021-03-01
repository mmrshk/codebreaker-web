# frozen_string_literal: true

require 'rack/test'
require 'simplecov'

require_relative '../autoload'

SimpleCov.start do
  minimum_coverage 95
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
