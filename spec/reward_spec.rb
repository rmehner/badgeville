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
    "image_url": "http://s3.amazon.com/original.png?1",
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
    "active": true,
    "message": "You won the internet!"
   }')
  end

  context "when json is a reward definition" do
    before do
      @reward = Badgeville::Reward.new(@parsed_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.active.should be_true
      @reward.id.should == "4e4dfab6c47eed727b005c38"
      @reward.definition_id.should == '4e4dfab6c47eed727b005c38'
      @reward.message.should == 'You won the internet!'
    end

    describe "image_url" do
      it "returns the original url by default" do
        @reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "allows to request specific formats" do
        [:original, :large, :medium, :grayscale, :grayscale_small].each do |format|
          @reward.image_url(format).should == "//s3.amazon.com/#{format}.png?1"
        end
      end

      it "returns a protocol relative url for a http original image url" do
        @reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "returns a protocol relative url for a https original image url" do
        @parsed_json['image_url'] = 'https://s3.amazon.com/original.png?1'
        reward = Badgeville::Reward.new(@parsed_json)

        reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "returns nil if the image url is nil in the parsed json" do
        @parsed_json['image_url'] = nil
        reward = Badgeville::Reward.new(@parsed_json)

        reward.image_url.should be_nil
      end
    end

    describe "tags" do
      it "returns an empty array if no tag key is in the parsed json" do
        @reward = Badgeville::Reward.new({})

        @reward.tags.should == []
      end

      it "returns an empty array if no tags are defined" do
        @reward = Badgeville::Reward.new('tags' => nil)

        @reward.tags.should == []
      end

      it "returns the defined tag" do
        @reward = Badgeville::Reward.new('tags' => ['tag'])

        @reward.tags.should == ["tag"]
      end

      it "returns all defined tags" do
        @reward = Badgeville::Reward.new('tags' =>['tag1', 'tag2'])

        @reward.tags.should == ['tag1', 'tag2']
      end
    end
  end

  context "when json is a reward earned by user" do
    before do
      @parsed_json = {"user_id" => "1", "id" => "new_id",
        "created_at" => "2011-08-18T22:55:03-07:00",
        "definition" => @parsed_json}
      @reward = Badgeville::Reward.new(@parsed_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.image_url.should =~ /original.png/
      @reward.active.should be_true
      @reward.earned_at.iso8601.should == Time.parse(@parsed_json["created_at"]).iso8601
      @reward.id.should == "new_id"
      @reward.definition_id.should == '4e4dfab6c47eed727b005c38'
      @reward.message.should == 'You won the internet!'
    end
  end

  context "when reward is an achievement (has data with verb and threshold)" do
    before do
      @reward = Badgeville::Reward.new(@parsed_json)
    end

    it "has verb and threshold accessors" do
      @reward.verb.should == "commented"
      @reward.threshold.should == 2
    end
  end
end
