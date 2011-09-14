require 'json'
require 'rest_client'
require 'badgeville/activity'
require 'badgeville/reward'

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
    attr_accessor :user, :site, :player_id, :site_id

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

    def get_activities(opts={})
      response = make_call(:get, :activities, opts)
      response["data"].map do |activity_json|
        Activity.new(activity_json)
      end
    end

    def count_activities(opts={})
      response = make_call(:get, :activities, opts)
      response["paging"]["total_entries"].to_i
    end

    def reward_definitions
      unless @reward_definitions
        response = make_call(:get, :reward_definitions)
        @reward_definitions = response["data"].inject([]) do
          |rewards, reward_json|
          rewards<< Reward.new(reward_json)
          rewards
        end
      end
      @reward_definitions
    end

    def get_rewards
      begin
        response = make_call(:get, :rewards)
        response["data"].map do |reward_json|
          Reward.new(reward_json)
        end
      rescue BadgevilleError => e
        raise e unless e.code == 404
        []
      end
    end

    def award reward_name
      reward = reward_definitions.select do |reward|
        reward.name == reward_name
      end.first
      params = {
        'reward[player_id]' => player_id,
        'reward[site_id]' => site_id,
        'reward[definition_id]' => reward.id,
      }
      Reward.new(make_call(:post, :rewards, params))
    end

    def set_player
      end_point = "#{@site}/players/#{@user}.json"
      begin
        response = session[end_point].get
        data = response.body
        json = JSON.parse(data)
        json = json["data"]
        @player_id = json["id"]
        @site_id = json["site_id"]
      rescue => e
        if e.respond_to? :response
          data = JSON.parse(e.response)
          raise BadgevilleError.new(e.http_code, data["error"])
        else
          raise e
        end
      end
    end

    def site_id
      unless @site_id
        set_player
      end
      @site_id
    end

    def player_id
      unless @player_id
        set_player
      end
      @player_id
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
      unless params.keys.any? { |k| k =~ /player_id/ }
        params.merge!(:user => @user, :site => @site)
      end
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
          begin
            data = JSON.parse(e.response)
            raise BadgevilleError.new(e.code, data["error"])
          rescue TypeError
            raise BadgevilleError.new(e.code, data)
          end
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
