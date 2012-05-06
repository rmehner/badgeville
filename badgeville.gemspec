# -*- encoding: utf-8 -*-
require File.expand_path('../lib/badgeville/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name             = "badgeville"
  gem.description      = "Badgeville API client"
  gem.summary          = "Client for Badgeville's Core API v2. http://rules.badgeville.com"
  gem.version          = Badgeville::VERSION
  gem.authors          = ["Gilad Buchman", "Robin Mehner"]
  gem.homepage         = "http://github.com/rmehner/badgeville"
  gem.date             = Time.now.utc.strftime("%Y-%m-%d")
  gem.licenses         = ["MIT"]

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.require_paths    = ["lib"]
  gem.rubygems_version = %q{1.6.2}

  gem.add_dependency 'rest-client'
  gem.add_dependency 'json'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'webmock'
end
