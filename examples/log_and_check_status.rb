#!/usr/bin/env ruby
require 'rubygems'
require 'badgeville'
require 'pp'

settings = JSON.parse(File.read('keys.json'))
badgeville = Badgeville::Client.new('me@example.com', settings)

pp badgeville.reward_definitions #all defined definitions for site

pp badgeville.log_activity "commented"

pp badgeville.log_activity "join_team", :team => "myteam"

pp badgeville.get_activities
pp badgeville.get_rewards #earned for user
