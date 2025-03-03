# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Repositories', 'app/repositories'
  add_group 'Middlewares', 'app/middlewares'
  add_group 'Services', 'app/services'
  add_group 'Lib', 'lib'
end

require 'rack/test'
require 'rspec'
require 'json'
require 'bcrypt'

require_relative '../app'

ENV['RACK_ENV'] = 'test'
LOGGER.level = Logger::ERROR

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App.new
  end

  config.before(:each) do
    Repositories::ProductRepository.instance_variable_set(:@products, Concurrent::Map.new)
    Repositories::ProductRepository.instance_variable_set(:@last_id, Concurrent::AtomicFixnum.new(0))
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def json_response
  JSON.parse(last_response.body)
end

def sign_in_user
  post '/auth/login', { username: 'admin', password: 'admin' }.to_json, 
       { 'content-type' => 'application/json' }
end

def stub_sync_creation
  allow(Repositories::ProductRepository).to receive(:create) do |name|
    id = Repositories::ProductRepository.instance_variable_get(:@last_id).increment
    products = Repositories::ProductRepository.instance_variable_get(:@products)
    products[id] = { id: id, name: name }
    id
  end
end