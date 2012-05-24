module Badgeville
  class Activity
    attr_accessor :verb, :player_id, :user_id, :points, :rewards, :created_at, :meta

    def initialize(json=nil)
      if json
        @verb       = json.delete("verb")
        @player_id  = json.delete("player_id")
        @user_id    = json.delete("user_id")
        @points     = json.delete("points").to_i
        @created_at = DateTime.parse(json.delete("created_at")).to_time

        @rewards = json.delete("rewards").map do |award|
          Reward.new(award)
        end

        @meta = json.inject({}) do |meta, entry|
          k,v            = entry
          meta[k.to_sym] = v
          meta
        end
      end
    end
  end
end
