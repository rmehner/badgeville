#!/usr/bin/env ruby
require 'rubygems'
require 'badgeville'
require 'pp'

settings = JSON.parse(File.read('keys.json'))
badgeville = Badgeville::Client.new('me@example.com', settings)

badgeville.log_activity "commented"

badgeville.log_activity "join_team", :team => "myteam"
