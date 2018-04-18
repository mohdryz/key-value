require_relative './src/variables.rb'
require_relative './src/communicate.rb'
require_relative './src/boot_handler.rb'
require_relative './src/exit_handler.rb'
# Dir['./src/*.rb'].each {|file| require file }
require 'sinatra'
require 'json'
require_relative './app.rb'

run Application
