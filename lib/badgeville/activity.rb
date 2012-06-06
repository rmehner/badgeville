module Badgeville
  class Activity < Endpoint
    ATTRIBUTES = [
      :contents, :definition_ids, :player_id, :player_type, :points, :src_player,
      :shard_id, :site_id, :user_id, :verb
    ]

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

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
        'activities.json',
        user_info.merge(
          activity: attributes.reject {|k, v| [:player_id, :site, :email].include?(k)}
        )
      )

      new(response)
    end

    def initialize(attributes = {})
      @attributes = attributes

      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", @attributes[attr.to_s])
      end

      @units = @attributes.select {|k, v| k =~ /^unit_/}
    end

    def created_at
      @created_at ||= Time.parse(@attributes['created_at'])
    end

    def deleted_at
      if !@deleted_at && @attributes['deleted_at']
        @deleted_at = Time.parse(@attributes['deleted_at'])
      end

      @deleted_at
    end

    def id
      @attributes['_id']
    end

    def internal?
      @attributes['internal']
    end

    def method_missing(method)
      @units[method.to_s] || super
    end

    def respond_to?(method)
      @units.keys.include?(method.to_s) || super
    end

    def rewards
      @rewards ||= @attributes['rewards'].map {|reward| Reward.new(reward)}
    end

    def points
      @points.to_i
    end

    def meta
      known_attributes = ATTRIBUTES + [
        :created_at, :deleted_at, :points, :rewards, :_id, :id, :internal
      ]

      @meta ||= @attributes.inject({}) do |meta, entry|
        key   = entry[0].to_sym
        value = entry[1]

        unless known_attributes.include?(key) || @units.keys.include?(key.to_s)
          meta[key] = value
        end

        meta
      end
    end
  end
end
