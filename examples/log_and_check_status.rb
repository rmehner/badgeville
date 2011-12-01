#!/usr/bin/env ruby
require 'rubygems'
require 'badgeville'
require 'pp'

settings = JSON.parse(File.read('keys.json'))
badgeville = Badgeville::Client.new('test_8@example.com', settings)

#turn on debugging
badgeville.debug = true

#create player on site
pp badgeville.create_player
pp badgeville.player_info

#pp badgeville.reward_definitions #all defined definitions for site

#pp badgeville.log_activity "commented"

#pp badgeville.log_activity "join_team", :team => "myteam"

#check histoy for user
#pp badgeville.get_activities
#pp badgeville.count_activities
#pp badgeville.count_activities :verb => "commented"
#pp badgeville.count_activities :verb => "junk"

#pp badgeville.get_rewards #earned for user

#award and delete rewards
#reward = badgeville.award "The First Step"
#badgeville.delete reward
