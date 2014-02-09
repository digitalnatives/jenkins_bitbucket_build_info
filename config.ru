#!/bin/env ruby

$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'bundler/setup'
Bundler.require :default

require './app'
run Sinatra::Application
