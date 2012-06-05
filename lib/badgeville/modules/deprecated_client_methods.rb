module Badgeville

  #
  # All methods in this module are deemed deprecated and will be removed
  # in a future release. Methods with proper alternatives throw
  # a warning with a hint for the new method.
  #
  module DeprecatedClientMethods
    attr_accessor :user, :site, :player_id, :site_id, :debug

    def debug=(flag)
      log_file       = flag ? "stdout" : nil
      RestClient.log = log_file
      @debug         = flag
    end

    def public_key=(public_key)
      warn '[DEPRECATED] public_key= is deprecated as it is not used anyway'
    end

    def create_player(opts = {})
      #try to see if player already exists
      begin
        return player_info
      rescue
      end

      #try to create user
      begin
        params   = property_params(:user, {email: @user}.merge(opts))
        response = make_call(:post, :users, params)
      rescue BadgevilleError => e
        if e.code != 422
          if ensure_array(e.data["email"]).none? {|erorr_msg|
            error_msg =~ "is already taken"
          }
            raise e
          end
        end
      end

      #create player
      params = {
        email: @user,
        site: @site
      }.merge(
        property_params(:player, {email: @user}.merge(opts))
      )
      json       = make_call(:post, :players, params)
      @site_id   = json["site_id"]
      @player_id = json["id"]
    end

    def log_activity(activity, opts = {})
      warn '[DEPRECATED] Please use Badgeville::Activity.create instead'
      params   = property_params(:activity, {verb: activity}.merge(opts))
      response = make_call(:post, :activities, params)
      Activity.new(response)
    end

    def get_activities(opts = {})
      response = make_call(:get, :activities, opts)
      response["data"].map do |activity_json|
        Activity.new(activity_json)
      end
    end

    def count_activities(opts = {})
      response = make_call(:get, :activities, opts.merge(:include_totals => true))
      response["paging"]["total_entries"].to_i
    end

    def reward_definitions
      warn '[DEPRECATED] Please use Badgeville::RewardDefinition.find_by_site instead'
      unless @reward_definitions
        pages               = all_pages_for(:reward_definitions)
        @reward_definitions = pages.inject([]) do |definitions, page|
          definitions += rewards_from_response(page)
        end
      end
      @reward_definitions
    end

    def get_rewards
      warn '[DEPRECATED] Please use Badgeville::Reward.find_by_player instead'
      begin
        pages = all_pages_for(:rewards)
        pages.inject([]) do |rewards, page|
          rewards += rewards_from_response(page)
        end
      rescue BadgevilleError => e
        raise e unless e.code == 404
        []
      end
    end

    def award(reward_name)
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

    def delete(reward)
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

    def player_info
      end_point = "/players/info.json"
      begin
        params     = {:email => @user, :site => @site}
        response   = session[end_point].get(:params => params)
        data       = response.body
        json       = JSON.parse(data)
        json       = json["data"]
        @site_id   = json["site_id"]
        @player_id = json["id"]
      rescue => e
        if e.respond_to? :response && e.response
          data = JSON.parse(e.response)
          raise BadgevilleError.new(e.http_code, data["errors"]["error"])
        else
          raise e
        end
      end
    end

    def site_id
      unless @site_id
        player_info
      end
      @site_id
    end

    def player_id
      unless @player_id
        player_info
      end
      @player_id
    end

  private

    def make_call(method, action, params = {})
      end_point = "#{action.to_s}.json"
      params = add_default_params(method, action, params)

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
        puts e if debug
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

    def to_query(params)
      URI.escape(params.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join("&"))
    end

    def add_default_params(method, action, params)
      should_not_add = params.keys.none? { |k| k =~ /player_id/ }
      should_not_add &= [:users, :players].include? action
      unless should_not_add
        params.merge!(:user => @user, :site => @site)
      end
      if method == :get && @per_page && !params.has_key?(:per_page)
        params[:per_page] = @per_page
      end
      params
    end

    def rewards_from_response(response)
      response["data"].map do |reward_json|
        Reward.new(reward_json)
      end
    end

    def get_page(action, page, params={})
      make_call(:get, action, params.merge(page: page))
    end

    def all_pages_for(action, params={})
      pages        = []
      current_page = 1
      total_pages  = nil

      while total_pages.nil? || current_page <= total_pages
        params[:include_totals] = true unless total_pages
        response = get_page(action, current_page, params)
        pages << response
        if response["paging"]
          current_page = response["paging"]["current_page"].to_i + 1
          total_pages  = response["paging"]["total_pages"].to_i if total_pages.nil?
        else
          total_pages = 0
        end
      end
      pages
    end
  end
end
