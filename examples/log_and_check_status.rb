#!/usr/bin/env ruby
require 'rubygems'
require 'badgeville'
require 'pp'

settings = JSON.parse(File.read('keys.json'))
badgeville = Badgeville::Client.new('4@keas.com', settings)

pp badgeville.log_activity "commented"
