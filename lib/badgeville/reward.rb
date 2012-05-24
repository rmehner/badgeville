module Badgeville
  class Reward
    include Badgeville::Helpers
    attr_accessor :name, :hint, :active, :earned_at, :id, :message
    attr_accessor :verb, :threshold, :tags, :definition_id

    attr_writer :image_url

#  example:
#  {
#    "name": "A Way with Words",
#    "active_start_at": null,
#    "image_file_name": "9fQ2IU6-0.ftbs4fsoogp3c8fr.png",
#    "data": {
#      "verb": "commented",
#      "threshold": 2
#    },
#    "created_at": "2011-08-18T22:55:03-07:00",
#    "image_url": "http://s3.amazonaws.com/badgeville-production-reward-definitions/images/original.png?1313733302",
#    "components": "[{\"command\":\"count\",\"comparator\":{\"$gte\":2},\"config\":{},\"where\":{\"verb\":\"commented\",\"player_id\":\"%player_id\"}}]",
#    "reward_template": {
#      "message": ""
#    },
#      "_id": "4e4dfab6c47eed727b005c38",
#    "tags": null,
#    "id": "4e4dfab6c47eed727b005c38",
#    "active_end_at": null,
#    "type": "achievement",
#    "hint": "Reply to 25 Comments",
#    "assignable": false,
#    "allow_duplicates": false,
#    "site_id": "4e4d5bf5c47eed25a0000e8f",
#    "active": true,
#    "message": "You won the internet!"
#   }
    def initialize(json=nil)
      if json
        reward_definition = json["definition"]
        reward_definition ? init_from(reward_definition) : init_from(json)
        if json.has_key?('user_id') # it's an earned reward for a specific user
          @earned_at = DateTime.parse(json["created_at"]).to_time
          @id        = json["id"]
        end
      end
    end

    def image_url(format = :original)
      @image_url.sub('original', format.to_s).sub(/^https?:/, '') if @image_url
    end

    # <b>DEPRECATED:</b> Please use <tt>image_url('grayscale')</tt> instead.
    def grayscale_url
      warn "[DEPRECATION] `grayscale_url` is deprecated.  Please use `image_url(:grayscale)` instead."
      image_url(:grayscale)
    end

    private

    def init_from(json)
      ['name', 'active', 'hint', 'image_url', 'message'].each do |key|
        send("#{key}=", json[key])
      end

      @id = @definition_id = json["_id"]

      if json["data"] && json["type"] == "achievement"
        @verb      = json["data"]["verb"]
        @threshold = json["data"]["threshold"].to_i
      end

      @tags = json['tags'] || []
    end
  end
end
