module Badgeville
  class Reward
    attr_accessor :name, :hint, :image_url, :active
  end

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
#    "image_url": "http://s3.amazonaws.com/badgeville-production-reward-definitions/images/4e4dfab6c47eed727b005c38/original.png?1313733302",
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
#    "active": true
#   }
  def initialize(json)
    @name = json["name"]
    @active = json["active"]
    @hint = json["hint"]
    @image_url = json["image_url"]
  end
end
