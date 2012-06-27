[![Build Status](https://secure.travis-ci.org/rmehner/badgeville.png)](http://travis-ci.org/rmehner/badgeville)

Badgeville API
==============

Client for Badgeville API http://rules.badgeville.com/

Note
====

We're in the process of rewriting this gem to have more features in a
cleaner and well tested way.

We work directly in master, so if you're brave and want to help, load the
master version in your app and report back if something breaks / doesn't work
as advertised. We're using master in one of our production apps and it works
fine so far.

If you want to have a _stable_ version, use the released one that is available
on rubygems.org. We'll keep the deprecated usage for the next release, but will
remove that eventually in near future.

Have a look at the [Changelog](https://github.com/rmehner/badgeville/blob/master/CHANGELOG.md)
to get a feeling of what changes and what is added with the upcoming version

Deprecated Usage
----------------
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

