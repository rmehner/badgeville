require 'json'
require 'rest_client'
require 'badgeville/helpers'
require 'badgeville/activity'
require 'badgeville/reward'

module Badgeville
  TIMEOUT_SECS = 3
  HOST         = "sandbox.v2.badgeville.com"
  PROTOCOL     = "http"
  MAX_PER_PAGE = 50

  class BadgevilleError < StandardError
    attr_accessor :code, :data

    def initialize (err_code=nil, error_data="")
      super error_data.to_s
      @data = error_data
      @code = err_code
    end

    def to_s
      "ERROR #{@code} : #{@data}"
    end
  end

  class Client
    attr_accessor :user, :site, :player_id, :site_id, :timeout

    def initialize (email, opts={})
      # Required Parameters
      @site = opts['site']
      @private_key = opts['private_key']
      @public_key = opts['public_key']
      @timeout = opts['timeout'] || TIMEOUT_SECS
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
        @reward_definitions  = []
        current_page         = 1
        response             = rewards_for_page(current_page)
        @reward_definitions += rewards_from_response(response)

        (response["paging"]["total_pages"].to_i - 1).times do
          @reward_definitions += rewards_from_response(
            rewards_for_page(current_page += 1)
          )
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

    def delete reward
      if reward.respond_to?(:earned_at) && reward.earned_at
        end_point = "rewards/#{reward.id}.json"
        begin
          !!session[end_point].delete
        rescue => e
          raise BadgevilleError.new(e.http_code, e.message)
        end
      else
        raise BadgevilleError.new(nil, "can only remove earned rewards. a #{reward.to_json} was given")
      end
    end

    def set_player
      end_point = "/players/info.json"
      begin
        response = session[end_point].get(:params =>
                                          {:email => @user, :site => @site})
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

    def session
      if @session.nil?
        base_url = "#{@protocol}://#{@host}/api/berlin/#{@private_key}"
        @session = RestClient::Resource.new base_url,
          :timeout => @timeout, :open_timeout => @timeout
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
            data.merge!(:params => params,
                        :end_point => end_point,
                        :method => method)
            raise BadgevilleError.new(e.http_code, data)
          rescue TypeError, JSON::ParserError
            msg = "#{e.message} on #{method} #{end_point}: #{params}"
            raise BadgevilleError.new(e.http_code, msg)
          end
        else
          raise e
        end
      end
    end

    def to_query params
      URI.escape(params.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join("&"))
    end

    def rewards_from_response(response)
      response["data"].map do |reward_json|
        Reward.new(reward_json)
      end
    end

    def rewards_for_page(page)
      make_call(:get, :reward_definitions, {per_page: MAX_PER_PAGE, page: page})
    end
  end
end
