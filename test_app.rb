require_relative './src/variables.rb'
Dir['./src/*.rb'].each {|file| require file }
require 'sinatra'
require_relative "./app.rb"
require 'json'
require "test/unit"
require 'rack/test'
require 'securerandom'
 
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
    resp = JSON.parse(last_response.body)
    assert_equal resp["sample"], "12"
  end

  def test_get_correct_sample_key_value
    get '/get/sample'
    assert last_response.ok?
    assert_equal "12", last_response.body
  end

  def test_get_correct_absent_key_value
    random_key = SecureRandom.hex
    get "/get/#{random_key}"
    assert last_response.ok?
    assert_equal "No Value Found Against Key: #{random_key}", last_response.body
  end

  def test_add_functionality
    key1, key2, val1, val2 = SecureRandom.hex, SecureRandom.hex, SecureRandom.hex, SecureRandom.hex
    data = {key1 => val1, key2 => val2}
    post '/add', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "Success", last_response.body

    get "/get/#{key1}"
    assert last_response.ok?
    assert_equal val1, last_response.body

    get "/get/#{key2}"
    assert last_response.ok?
    assert_equal val2, last_response.body
  end

  def test_set_functionality
    key = SecureRandom.hex
    post "/set/#{key}", "the quick brown fox"
    assert last_response.ok?
    assert_equal "Success", last_response.body

    get "/get/#{key}"
    assert last_response.ok?
    assert_equal "the quick brown fox", last_response.body
  end

  def test_remove_random_key
    random_key = SecureRandom.hex
    post "/remove/#{random_key}"
    assert last_response.ok?
    assert_equal "No Value Found Against Key: #{random_key}", last_response.body
  end

  def test_remove_correct_key
    random_key = SecureRandom.hex
    post "/set/#{random_key}", "the quick brown fox"
    assert last_response.ok?
    assert_equal "Success", last_response.body

    get "/get/#{random_key}"
    assert last_response.ok?
    assert_equal "the quick brown fox", last_response.body

    post "/remove/#{random_key}"
    assert last_response.ok?
    assert_equal "Success", last_response.body

    get "/get/#{random_key}"
    assert last_response.ok?
    assert_equal "No Value Found Against Key: #{random_key}", last_response.body
  end
  
end
