require 'json'
require 'rest_client'
require 'badgeville/activity'

module Badgeville
  TIMEOUT = 1000
  HOST = "sandbox.v2.badgeville.com"
  PROTOCOL = "http"

  class BadgevilleError < StandardError
    attr_accessor :code

    def initialize (err_code=nil)
      @code = err_code
    end
  end

  class Client

    def initialize (email, opts={})
      # Required Parameters
      @site = opts['site']
      @private_key = opts['private_key']
      @public_key = opts['public_key']
      @host = opts['host'] || HOST
      @protocol = opts['protocol'] || PROTOCOL
      @user = email
    end

    def log_activity(activity, opts={})
      params = {
        "activity[verb]" => activity,
      }
      opts.inject(params) do |params, entry|
        k, v = entry
        params["activity[#{k.to_s}]"] = v
        params
      end
      response = make_call(:post, :activities, params)
      Activity.new(response)
    end

    def get_activities
      response = make_call(:get, :activities)
      response["data"].inject([]) do |activities, activity_json|
        activities<< Activity.new(activity_json)
        activities
      end
    end

    private

    def valid_response?(obj)
      obj.is_a?(Array) || obj.is_a?(Hash)
    end

    def ensure_array(items)
      items.is_a?(Array) ? items : [items]
    end

    def session
      if @session.nil?
        base_url = "#{@protocol}://#{@host}/api/berlin/#{@private_key}"
        @session = RestClient::Resource.new base_url
      end
      @session
    end

    def make_call(method, action, params={})
      end_point = "#{action.to_s}.json"
      params.merge!(:user => @user, :site => @site)
      begin
        case method
        when :get
          response = session[end_point].send(method, :params => params)
        when :post, :put, :delete
          response = session[end_point].send(method, to_query(params))
        end
        data = response.body
        json = JSON.parse(data)
      rescue => e
        if e.respond_to? :response
          data = JSON.parse(e.response)
          raise BadgevilleError.new(e.code, data["error"])
        else
          raise e
        end
      end
    end

    def to_query params
      URI.escape(params.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join("&"))
    end
  end
end
