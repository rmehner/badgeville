#!/usr/bin/env ruby
require 'rubygems'
require 'badgeville'
require 'pp'

settings = JSON.parse(File.read('keys.json'))
badgeville = Badgeville::Client.new('test@keas.com', settings)

pp badgeville.reward_definitions

pp badgeville.log_activity "commented"

pp badgeville.log_activity "join_team", :team => "myteam"

pp badgeville.get_activities
