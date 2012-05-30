module Badgeville
  class Activity < Endpoint
    attr_accessor :verb, :player_id, :user_id, :points

    def self.create(attributes)
      if (!attributes[:player_id]) && (!attributes[:email] || !attributes[:site])
        raise ArgumentError.new('You have to provide a player_id or a site and email')
      end

      user_info = {}
      if attributes[:player_id]
        user_info[:player_id] = attributes[:player_id]
      else
        user_info[:site]  = attributes[:site]
        user_info[:email] = attributes[:email]
      end

      response = client.post(
        '/activities.json',
        user_info.merge(
          activity: attributes.reject {|k, v| [:player_id, :site, :email].include?(k)}
        )
      )

      new(response)
    end

    def initialize(json = {})
      @json      = json
      @verb      = @json['verb']
      @player_id = @json['player_id']
      @user_id   = @json['user_id']
      @points    = @json['points'].to_i
    end

    def rewards
      @rewards ||= @json['rewards'].map {|reward| Reward.new(reward)}
    end

    def created_at
      @created_at ||= DateTime.parse(@json['created_at']).to_time
    end

    def meta
      known_attributes = [:created_at, :player_id, :points, :rewards, :user_id, :verb]
      @meta ||= @json.inject({}) do |meta, entry|
        key   = entry[0].to_sym
        value = entry[1]

        unless known_attributes.include?(key)
          meta[key] = value
        end

        meta
      end
    end
  end
end
