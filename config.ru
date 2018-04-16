require_relative './src/variables.rb'
Dir['./src/*.rb'].each {|file| require file }
require 'sinatra'
require 'json'
require_relative './app.rb'

run Application