require 'json'
require 'rest_client'
require 'badgeville/endpoint'
require 'badgeville/activity'
require 'badgeville/error'
require 'badgeville/helpers'
require 'badgeville/player'
require 'badgeville/user'
require 'badgeville/reward_definition'
require 'badgeville/reward'
require 'badgeville/version'
require 'badgeville/modules/deprecated_client_methods'
require 'badgeville/client'

module Badgeville
  def self.configure(opts = {})
    self.client = Badgeville::Client.new('', opts)
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
