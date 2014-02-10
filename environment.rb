$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'bundler/setup'
Bundler.require :default

require 'dotenv'
Dotenv.load if defined?(Dotenv)

