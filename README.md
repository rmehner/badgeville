Badgeville API
============

Client for Badgeville API http://rules.badgeville.com/

(not complete)

Usage
--------
First, checkout the examples folder. TL;DR:

* create connection object with your api_key, and secret.

```ruby
require 'badgeville'
settings = JSON.parse(File.read('keys.json.example'))
badgeville = Badgeville::Client.new(email, settings)
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

