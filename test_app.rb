require_relative './src/variables.rb'
Dir['./src/*.rb'].each {|file| require file }
require 'sinatra'
require_relative "./app.rb"
require 'json'
require "test/unit"
require 'rack/test'
 
class TestApplication < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Application
  end
 
  def test_get_correct_empty_response
    get '/'
    assert last_response.ok?
    assert_equal "Distributed Key-Value Store", last_response.body
  end

  def test_get_correct_sample_hash
    get '/values'
    assert last_response.ok?
    assert_equal "{\"sample\":\"12\"}", last_response.body
  end

  def test_get_correct_sample_key_value
    get '/get/sample'
    assert last_response.ok?
    assert_equal "12", last_response.body
  end

  def test_get_correct_absent_key_value
    get '/get/randomkey'
    assert last_response.ok?
    assert_equal "No Value Found Against Key: randomkey", last_response.body
  end

  
 
end