require 'json'
require 'time'
require 'rest_client'
require 'badgeville/endpoint'
require 'badgeville/activity'
require 'badgeville/errors'
require 'badgeville/player'
require 'badgeville/user'
require 'badgeville/reward_definition'
require 'badgeville/reward'
require 'badgeville/group'
require 'badgeville/version'
require 'badgeville/modules/deprecated_client_methods'
require 'badgeville/client'

module Badgeville
  def self.configure(opts = {})
    self.client = Client.new('')

    if block_given?
      yield self.client
    else
      opts.each do |option, value|
        self.client.send("#{option}=", value)
      end
    end
  end

  def self.client=(client)
    @client = client
  end

  def self.client
    unless @client
      raise 'Please configure the Badgeville Client with your config'
    end

    @client
  end
end
