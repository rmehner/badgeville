require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'

describe Badgeville::Reward do
  before do
    @parsed_json = JSON.parse('{
    "name": "A Way with Words",
    "active_start_at": null,
    "image_file_name": "9fQ2IU6-0.ftbs4fsoogp3c8fr.png",
    "data": {
      "verb": "commented",
      "threshold": 2
    },
    "created_at": "2011-08-18T22:55:03-07:00",
    "image_url": "http://s3.amazonaws.com/badgeville-production-reward-definitions/images/someid/original.png?1313733302",
    "components": "[{\"command\":\"count\",\"comparator\":{\"$gte\":2},\"config\":{},\"where\":{\"verb\":\"commented\",\"player_id\":\"%player_id\"}}]",
    "reward_template": {
      "message": ""
    },
      "_id": "4e4dfab6c47eed727b005c38",
    "tags": null,
    "id": "4e4dfab6c47eed727b005c38",
    "active_end_at": null,
    "type": "achievement",
    "hint": "Reply to 25 Comments",
    "assignable": false,
    "allow_duplicates": false,
    "site_id": "4e4d5bf5c47eed25a0000e8f",
    "active": true
   }')
  end

  context "when json is a reward definition" do
    before do
      @reward = Badgeville::Reward.new(@parsed_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.image_url.should =~ /original.png/
      @reward.active.should be_true
    end

    it "has an grayscale image" do
      @reward.grayscale_url.should == @reward.image_url.sub('original','grayscale')
    end
  end

  context "when json is a reward earned by user" do
    before do
      @parsed_json = {"user_id" => "1", 
        "created_at" => "2011-08-18T22:55:03-07:00",
        "definition" => @parsed_json}
      @reward = Badgeville::Reward.new(@parsed_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.image_url.should =~ /original.png/
      @reward.active.should be_true
      @reward.earned_at.iso8601.should == @parsed_json["created_at"]
    end
  end
end
