[![Build Status](https://secure.travis-ci.org/rmehner/badgeville.png)](http://travis-ci.org/rmehner/badgeville)

Badgeville API
============

note: NOT ACTIVELY DEVELOPED - feel free to fork and run with it

Client for Badgeville API http://rules.badgeville.com/

Usage
--------
First, checkout the examples folder. TL;DR:

* create connection object with your api_key, and secret.

```ruby
require 'badgeville'
settings = JSON.parse(File.read('keys.json.example'))
badgeville = Badgeville::Client.new(email, settings)
```

* register user and player on site

```ruby
badgeville.create_player
```

* get player id

```ruby
badgeville.player_info
```

* log actions

```ruby
badgeville.log_activity "commented"
```

* get all logged activities

```ruby
badgeville.get_activities
```

* get list of reward definitions

```ruby
badgeville.reward_definitions
```

* manually award some reward

```ruby
badgeville.award "Best User"
```

Installing
----------
 1) add to your Gemfile

```
gem 'badgeville'
```

 2) Create a keys.json file with your api_key and secret (see keys.json.example file)

