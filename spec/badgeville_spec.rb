require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Badgeville do
  before do
    @user = "user"
    @badgeville = Badgeville::Client.new @user, 'private_key' => "api_key",
      'site' => 'example.com'
  end

  describe "#log_activity" do
    before do
      action_name = "action"
      @result = {"verb" => "commented",
        "created_at" => "2011-08-30T12:27:47-07:00",
        "points" => 0,
        "player_id" => "4e5d3992c47eed202d00148c",
        "user_id" => "4e5d3992c47eed202d00148b",
        "rewards" =>[]
      }

      body = "activity[verb]=#{action_name}&user=#{@user}&site=example.com"
      url = "http://" + Badgeville::HOST + ".*activities.json"

      stub_http_request(:post, Regexp.new(url)).with(:body => body).
        to_return(:body => @result.to_json)

      @activity =  @badgeville.log_activity action_name
    end

    it "parses response from activity record api call" do
      @activity.verb.should == "commented"
      @activity.created_at.iso8601.should == @result["created_at"]
      @activity.points.should == 0
      @activity.rewards.should be_empty
    end
  end
end
