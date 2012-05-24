require 'json'
require 'rest_client'
require 'badgeville/error'
require 'badgeville/helpers'
require 'badgeville/activity'
require 'badgeville/reward'
require 'badgeville/version'
require 'badgeville/client'

module Badgeville
  TIMEOUT_SECS = 3
  HOST         = "sandbox.v2.badgeville.com"
  PROTOCOL     = "http"
end
